#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>
#include <shlobj.h>

#include <cstdint>
#include <cstdlib>
#include <string>

#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "shell32.lib")

namespace {

std::wstring PortFilePath() {
  wchar_t* path = nullptr;
  if (FAILED(SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, nullptr, &path))) {
    return {};
  }
  std::wstring file(path);
  CoTaskMemFree(path);
  file += L"\\OpenKey\\openkey-native.port";
  return file;
}

std::wstring TokenFilePath() {
  wchar_t* path = nullptr;
  if (FAILED(SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, nullptr, &path))) {
    return {};
  }
  std::wstring file(path);
  CoTaskMemFree(path);
  file += L"\\OpenKey\\openkey-native.token";
  return file;
}

int ReadPort() {
  const auto path = PortFilePath();
  if (path.empty()) return -1;
  HANDLE file = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr,
                            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) return -1;
  char buf[32] = {};
  DWORD read = 0;
  const BOOL ok = ReadFile(file, buf, sizeof(buf) - 1, &read, nullptr);
  CloseHandle(file);
  if (!ok || read == 0) return -1;
  return std::atoi(buf);
}

std::string ReadToken() {
  char* override_token = nullptr;
  size_t override_len = 0;
  if (_dupenv_s(&override_token, &override_len, "OPENKEY_NATIVE_TOKEN") == 0 &&
      override_token != nullptr) {
    std::string value;
    if (override_token[0] != '\0') value = override_token;
    free(override_token);
    if (!value.empty()) return value;
  }
  const auto path = TokenFilePath();
  if (path.empty()) return {};
  HANDLE file = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr,
                            OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) return {};
  char buf[128] = {};
  DWORD read = 0;
  const BOOL ok = ReadFile(file, buf, sizeof(buf) - 1, &read, nullptr);
  CloseHandle(file);
  if (!ok || read == 0) return {};
  while (read > 0 &&
         (buf[read - 1] == '\n' || buf[read - 1] == '\r' ||
          buf[read - 1] == ' ')) {
    --read;
  }
  return std::string(buf, read);
}

std::string WithAuth(const std::string& msg, const std::string& token) {
  if (token.empty()) return msg;
  const auto pos = msg.find('{');
  if (pos == std::string::npos) return msg;
  return msg.substr(0, pos + 1) + "\"auth\":\"" + token + "\"," +
         msg.substr(pos + 1);
}

bool ReadExact(HANDLE handle, void* data, DWORD size) {
  auto* bytes = static_cast<char*>(data);
  DWORD total = 0;
  while (total < size) {
    DWORD chunk = 0;
    if (!ReadFile(handle, bytes + total, size - total, &chunk, nullptr) ||
        chunk == 0) {
      return false;
    }
    total += chunk;
  }
  return true;
}

bool WriteExact(HANDLE handle, const void* data, DWORD size) {
  const auto* bytes = static_cast<const char*>(data);
  DWORD total = 0;
  while (total < size) {
    DWORD chunk = 0;
    if (!WriteFile(handle, bytes + total, size - total, &chunk, nullptr)) {
      return false;
    }
    total += chunk;
  }
  return true;
}

bool ReadChromeMessage(std::string* out) {
  HANDLE in = GetStdHandle(STD_INPUT_HANDLE);
  uint32_t length = 0;
  if (!ReadExact(in, &length, 4)) return false;
  if (length == 0 || length > 2 * 1024 * 1024) return false;
  out->assign(length, '\0');
  return ReadExact(in, out->data(), length);
}

bool WriteChromeMessage(const std::string& msg) {
  HANDLE out = GetStdHandle(STD_OUTPUT_HANDLE);
  const uint32_t length = static_cast<uint32_t>(msg.size());
  if (!WriteExact(out, &length, 4)) return false;
  return WriteExact(out, msg.data(), length);
}

std::string ForwardToApp(const std::string& msg) {
  const int port = ReadPort();
  if (port <= 0 || port > 65535) {
    return R"({"ok":false,"error":"OpenKey is not running or vault is locked"})";
  }

  SOCKET sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (sock == INVALID_SOCKET) {
    return R"({"ok":false,"error":"socket() failed"})";
  }

  sockaddr_in addr{};
  addr.sin_family = AF_INET;
  addr.sin_port = htons(static_cast<u_short>(port));
  inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);

  DWORD timeout_ms = 2500;
  setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
             reinterpret_cast<const char*>(&timeout_ms), sizeof(timeout_ms));
  setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,
             reinterpret_cast<const char*>(&timeout_ms), sizeof(timeout_ms));

  if (connect(sock, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) != 0) {
    closesocket(sock);
    return R"({"ok":false,"error":"Cannot connect to OpenKey"})";
  }

  const std::string payload = WithAuth(msg, ReadToken());
  const uint32_t length = static_cast<uint32_t>(payload.size());
  if (send(sock, reinterpret_cast<const char*>(&length), 4, 0) != 4 ||
      send(sock, payload.data(), static_cast<int>(payload.size()), 0) !=
          static_cast<int>(payload.size())) {
    closesocket(sock);
    return R"({"ok":false,"error":"Failed to send to OpenKey"})";
  }

  uint32_t resp_len = 0;
  if (recv(sock, reinterpret_cast<char*>(&resp_len), 4, MSG_WAITALL) != 4 ||
      resp_len == 0 || resp_len > 2 * 1024 * 1024) {
    closesocket(sock);
    return R"({"ok":false,"error":"Empty response from OpenKey"})";
  }

  std::string response(resp_len, '\0');
  int got = 0;
  while (got < static_cast<int>(resp_len)) {
    const int n =
        recv(sock, response.data() + got, static_cast<int>(resp_len) - got, 0);
    if (n <= 0) {
      closesocket(sock);
      return R"({"ok":false,"error":"Truncated response from OpenKey"})";
    }
    got += n;
  }
  closesocket(sock);
  return response;
}

}  // namespace

int main() {
  WSADATA wsa{};
  if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) {
    WriteChromeMessage(R"({"ok":false,"error":"WSAStartup failed"})");
    return 1;
  }

  CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  while (true) {
    std::string msg;
    if (!ReadChromeMessage(&msg)) break;
    WriteChromeMessage(ForwardToApp(msg));
  }

  CoUninitialize();
  WSACleanup();
  return 0;
}
