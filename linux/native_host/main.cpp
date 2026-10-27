#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

#include <string>

namespace {

constexpr size_t kMaxMessage = 2 * 1024 * 1024;

std::string SocketPath() {
  if (const char* override_path = getenv("OPENKEY_NATIVE_SOCKET")) {
    if (override_path[0] != '\0') return override_path;
  }
  if (const char* runtime = getenv("XDG_RUNTIME_DIR")) {
    if (runtime[0] != '\0') {
      return std::string(runtime) + "/openkey-native.sock";
    }
  }
  if (const char* tmp = getenv("TMPDIR")) {
    if (tmp[0] != '\0') {
      return std::string(tmp) + "/openkey-native.sock";
    }
  }
  return "/tmp/openkey-native.sock";
}

std::string TokenPathForSocket(const std::string& socket_path) {
  const auto slash = socket_path.find_last_of('/');
  if (slash == std::string::npos) return "openkey-native.token";
  return socket_path.substr(0, slash + 1) + "openkey-native.token";
}

std::string ReadFileTrimmed(const std::string& path) {
  FILE* f = fopen(path.c_str(), "rb");
  if (!f) return {};
  std::string out;
  char buf[256];
  while (true) {
    const size_t n = fread(buf, 1, sizeof(buf), f);
    if (n == 0) break;
    out.append(buf, n);
  }
  fclose(f);
  while (!out.empty() &&
         (out.back() == '\n' || out.back() == '\r' || out.back() == ' ')) {
    out.pop_back();
  }
  return out;
}

std::string BridgeAuthToken(const std::string& socket_path) {
  if (const char* override_token = getenv("OPENKEY_NATIVE_TOKEN")) {
    if (override_token[0] != '\0') return override_token;
  }
  return ReadFileTrimmed(TokenPathForSocket(socket_path));
}

// Inject "auth":"<token>" after the first '{' of a JSON object.
std::string WithAuth(const std::string& msg, const std::string& token) {
  if (token.empty()) return msg;
  const auto pos = msg.find('{');
  if (pos == std::string::npos) return msg;
  return msg.substr(0, pos + 1) + "\"auth\":\"" + token + "\"," +
         msg.substr(pos + 1);
}

bool ReadExact(FILE* in, void* data, size_t size) {
  auto* bytes = static_cast<uint8_t*>(data);
  size_t total = 0;
  while (total < size) {
    const size_t n = fread(bytes + total, 1, size - total, in);
    if (n == 0) return false;
    total += n;
  }
  return true;
}

bool WriteExact(FILE* out, const void* data, size_t size) {
  auto* bytes = static_cast<const uint8_t*>(data);
  size_t total = 0;
  while (total < size) {
    const size_t n = fwrite(bytes + total, 1, size - total, out);
    if (n == 0) return false;
    total += n;
  }
  return fflush(out) == 0;
}

bool ReadChromeMessage(std::string* out) {
  uint32_t length = 0;
  if (!ReadExact(stdin, &length, 4)) return false;
  if (length == 0 || length > kMaxMessage) return false;
  out->assign(length, '\0');
  return ReadExact(stdin, out->data(), length);
}

bool WriteChromeMessage(const std::string& msg) {
  const uint32_t length = static_cast<uint32_t>(msg.size());
  if (!WriteExact(stdout, &length, 4)) return false;
  return WriteExact(stdout, msg.data(), msg.size());
}

bool RecvExact(int fd, void* data, size_t size) {
  auto* bytes = static_cast<uint8_t*>(data);
  size_t total = 0;
  while (total < size) {
    const ssize_t n = recv(fd, bytes + total, size - total, 0);
    if (n <= 0) return false;
    total += static_cast<size_t>(n);
  }
  return true;
}

bool SendExact(int fd, const void* data, size_t size) {
  auto* bytes = static_cast<const uint8_t*>(data);
  size_t total = 0;
  while (total < size) {
    const ssize_t n = send(fd, bytes + total, size - total, 0);
    if (n <= 0) return false;
    total += static_cast<size_t>(n);
  }
  return true;
}

std::string ForwardToApp(const std::string& msg) {
  const std::string path = SocketPath();
  int fd = socket(AF_UNIX, SOCK_STREAM, 0);
  if (fd < 0) {
    return R"({"ok":false,"error":"socket() failed"})";
  }

  sockaddr_un addr{};
  addr.sun_family = AF_UNIX;
  if (path.size() >= sizeof(addr.sun_path)) {
    close(fd);
    return R"({"ok":false,"error":"Socket path too long"})";
  }
  memcpy(addr.sun_path, path.c_str(), path.size() + 1);

  if (connect(fd, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) {
    close(fd);
    return R"({"ok":false,"error":"OpenKey is not running or vault is locked"})";
  }

  const std::string payload = WithAuth(msg, BridgeAuthToken(path));
  const uint32_t length = static_cast<uint32_t>(payload.size());
  if (!SendExact(fd, &length, 4) || !SendExact(fd, payload.data(), payload.size())) {
    close(fd);
    return R"({"ok":false,"error":"Failed to send to OpenKey"})";
  }

  uint32_t resp_len = 0;
  if (!RecvExact(fd, &resp_len, 4) || resp_len == 0 || resp_len > kMaxMessage) {
    close(fd);
    return R"({"ok":false,"error":"Empty response from OpenKey"})";
  }

  std::string response(resp_len, '\0');
  if (!RecvExact(fd, response.data(), resp_len)) {
    close(fd);
    return R"({"ok":false,"error":"Truncated response from OpenKey"})";
  }
  close(fd);
  return response;
}

}  // namespace

int main() {
  // Native messaging hosts must only write framed JSON to stdout.
  setvbuf(stdin, nullptr, _IONBF, 0);
  setvbuf(stdout, nullptr, _IONBF, 0);

  while (true) {
    std::string msg;
    if (!ReadChromeMessage(&msg)) break;
    WriteChromeMessage(ForwardToApp(msg));
  }
  return 0;
}
