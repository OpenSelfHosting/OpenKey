#include "autofill_bridge.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <shlobj.h>
#include <windows.h>

#include <fstream>
#include <iterator>
#include <memory>
#include <string>
#include <vector>

namespace {

std::wstring LocalOpenKeyDir() {
  wchar_t* path = nullptr;
  if (FAILED(SHGetKnownFolderPath(FOLDERID_LocalAppData, 0, nullptr, &path))) {
    return {};
  }
  std::wstring dir(path);
  CoTaskMemFree(path);
  dir += L"\\OpenKey";
  CreateDirectoryW(dir.c_str(), nullptr);
  return dir;
}

std::string WideToUtf8(const std::wstring& wide) {
  if (wide.empty()) return {};
  const int size =
      WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), -1, nullptr, 0, nullptr, nullptr);
  if (size <= 1) return {};
  std::string out(static_cast<size_t>(size - 1), '\0');
  WideCharToMultiByte(CP_UTF8, 0, wide.c_str(), -1, out.data(), size, nullptr,
                      nullptr);
  return out;
}

std::wstring NativeHostExePath() {
  wchar_t module[MAX_PATH] = {};
  GetModuleFileNameW(nullptr, module, MAX_PATH);
  std::wstring path(module);
  const auto slash = path.find_last_of(L"\\/");
  if (slash != std::wstring::npos) {
    path = path.substr(0, slash + 1);
  }
  path += L"openkey_native_host.exe";
  return path;
}

std::wstring ManifestPath() {
  return LocalOpenKeyDir() + L"\\com.openselfhosting.openkey.json";
}

std::wstring CredentialsPath() {
  return LocalOpenKeyDir() + L"\\openkey-autofill-creds.json";
}

std::wstring ExtensionIdPath() {
  return LocalOpenKeyDir() + L"\\chrome_extension_id.txt";
}

std::string EscapeJson(const std::string& value) {
  std::string out;
  out.reserve(value.size());
  for (char c : value) {
    switch (c) {
      case '\\':
        out += "\\\\";
        break;
      case '"':
        out += "\\\"";
        break;
      case '\n':
        out += "\\n";
        break;
      case '\r':
        out += "\\r";
        break;
      case '\t':
        out += "\\t";
        break;
      default:
        out += c;
        break;
    }
  }
  return out;
}

std::string ReadChromeExtensionId() {
  const auto path = ExtensionIdPath();
  std::ifstream in(WideToUtf8(path), std::ios::binary);
  if (!in) return {};
  return std::string((std::istreambuf_iterator<char>(in)),
                     std::istreambuf_iterator<char>());
}

std::string OriginsBlock() {
  const std::string raw = ReadChromeExtensionId();
  std::string origins = "  \"allowed_origins\": [\n";
  std::string cur;
  std::vector<std::string> ids;
  auto flush = [&]() {
    std::string id = cur;
    cur.clear();
    auto trim = [](std::string& s) {
      while (!s.empty() && (s.back() == '\r' || s.back() == '\n' ||
                            s.back() == ' ' || s.back() == '\t' ||
                            s.back() == '/')) {
        s.pop_back();
      }
      size_t i = 0;
      while (i < s.size() &&
             (s[i] == ' ' || s[i] == '\t' || s[i] == '\r' || s[i] == '\n')) {
        ++i;
      }
      s.erase(0, i);
    };
    trim(id);
    const char* prefix = "chrome-extension://";
    if (id.size() > 19 && id.compare(0, 19, prefix) == 0) {
      id = id.substr(19);
      auto slash = id.find('/');
      if (slash != std::string::npos) id = id.substr(0, slash);
    }
    for (char& c : id) {
      if (c >= 'A' && c <= 'P') c = static_cast<char>(c - 'A' + 'a');
    }
    bool ok = id.size() == 32;
    for (char c : id) {
      if (c < 'a' || c > 'p') ok = false;
    }
    if (ok) ids.push_back(id);
  };
  for (char c : raw) {
    if (c == ',' || c == ';' || c == ' ' || c == '\n' || c == '\r' || c == '\t') {
      flush();
    } else {
      cur.push_back(c);
    }
  }
  flush();
  for (size_t i = 0; i < ids.size(); ++i) {
    origins += "    \"chrome-extension://" + EscapeJson(ids[i]) + "/\"";
    if (i + 1 < ids.size()) origins += ",";
    origins += "\n";
  }
  origins += "  ],\n";
  return origins;
}

bool WriteManifest(const std::wstring& host_exe) {
  const auto manifest = ManifestPath();
  const std::string host_utf8 = WideToUtf8(host_exe);
  std::string host_json = EscapeJson(host_utf8);
  const std::string origins_block = OriginsBlock();

  const std::string body =
      "{\n"
      "  \"name\": \"com.openselfhosting.openkey\",\n"
      "  \"description\": \"OpenKey native messaging host\",\n"
      "  \"path\": \"" +
      host_json +
      "\",\n"
      "  \"type\": \"stdio\",\n" +
      origins_block +
      "  \"allowed_extensions\": [\n"
      "    \"openkey@openselfhosting.local\"\n"
      "  ]\n"
      "}\n";

  HANDLE file = CreateFileW(manifest.c_str(), GENERIC_WRITE, 0, nullptr,
                            CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) return false;
  DWORD written = 0;
  const BOOL ok =
      WriteFile(file, body.data(), static_cast<DWORD>(body.size()), &written,
                nullptr);
  CloseHandle(file);
  return ok && written == body.size();
}

bool SetRegistryHost(const wchar_t* subkey, const std::wstring& manifest) {
  HKEY key = nullptr;
  const LONG create = RegCreateKeyExW(HKEY_CURRENT_USER, subkey, 0, nullptr, 0,
                                      KEY_SET_VALUE, nullptr, &key, nullptr);
  if (create != ERROR_SUCCESS) return false;
  const LONG set = RegSetValueExW(
      key, nullptr, 0, REG_SZ,
      reinterpret_cast<const BYTE*>(manifest.c_str()),
      static_cast<DWORD>((manifest.size() + 1) * sizeof(wchar_t)));
  RegCloseKey(key);
  return set == ERROR_SUCCESS;
}

bool RegisterNativeMessagingHost() {
  const auto host = NativeHostExePath();
  if (GetFileAttributesW(host.c_str()) == INVALID_FILE_ATTRIBUTES) {
    return false;
  }
  if (!WriteManifest(host)) return false;
  const auto manifest = ManifestPath();

  const bool chrome = SetRegistryHost(
      L"Software\\Google\\Chrome\\NativeMessagingHosts\\com.openselfhosting.openkey",
      manifest);
  const bool edge = SetRegistryHost(
      L"Software\\Microsoft\\Edge\\NativeMessagingHosts\\com.openselfhosting.openkey",
      manifest);
  const bool firefox = SetRegistryHost(
      L"Software\\Mozilla\\NativeMessagingHosts\\com.openselfhosting.openkey",
      manifest);
  return chrome || edge || firefox;
}

bool IsNativeMessagingRegistered() {
  HKEY key = nullptr;
  const LONG open = RegOpenKeyExW(
      HKEY_CURRENT_USER,
      L"Software\\Google\\Chrome\\NativeMessagingHosts\\com.openselfhosting.openkey",
      0, KEY_READ, &key);
  if (open == ERROR_SUCCESS) {
    RegCloseKey(key);
    return true;
  }
  const LONG open_edge = RegOpenKeyExW(
      HKEY_CURRENT_USER,
      L"Software\\Microsoft\\Edge\\NativeMessagingHosts\\com.openselfhosting.openkey",
      0, KEY_READ, &key);
  if (open_edge == ERROR_SUCCESS) {
    RegCloseKey(key);
    return true;
  }
  const LONG open_ff = RegOpenKeyExW(
      HKEY_CURRENT_USER,
      L"Software\\Mozilla\\NativeMessagingHosts\\com.openselfhosting.openkey",
      0, KEY_READ, &key);
  if (open_ff == ERROR_SUCCESS) {
    RegCloseKey(key);
    return true;
  }
  return false;
}

void WriteCredentialsJson(const std::string& json) {
  const auto path = CredentialsPath();
  HANDLE file = CreateFileW(path.c_str(), GENERIC_WRITE, 0, nullptr,
                            CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
  if (file == INVALID_HANDLE_VALUE) return;
  DWORD written = 0;
  WriteFile(file, json.data(), static_cast<DWORD>(json.size()), &written,
            nullptr);
  CloseHandle(file);
}

void ClearCredentialsJson() {
  DeleteFileW(CredentialsPath().c_str());
}

std::string CredentialsToJson(
    const flutter::EncodableList& raw) {
  std::string out = "[";
  bool first = true;
  for (const auto& item : raw) {
    const auto* map = std::get_if<flutter::EncodableMap>(&item);
    if (!map) continue;
    if (!first) out += ",";
    first = false;
    auto get = [&](const char* key) -> std::string {
      const auto it = map->find(flutter::EncodableValue(key));
      if (it == map->end()) return {};
      if (const auto* s = std::get_if<std::string>(&it->second)) return *s;
      return {};
    };
    out += "{\"uuid\":\"" + EscapeJson(get("uuid")) + "\",";
    out += "\"title\":\"" + EscapeJson(get("title")) + "\",";
    out += "\"username\":\"" + EscapeJson(get("username")) + "\",";
    out += "\"password\":\"" + EscapeJson(get("password")) + "\",";
    out += "\"urls\":[";
    const auto urls_it = map->find(flutter::EncodableValue("urls"));
    bool url_first = true;
    if (urls_it != map->end()) {
      if (const auto* urls = std::get_if<flutter::EncodableList>(&urls_it->second)) {
        for (const auto& u : *urls) {
          if (const auto* s = std::get_if<std::string>(&u)) {
            if (!url_first) out += ",";
            url_first = false;
            out += "\"" + EscapeJson(*s) + "\"";
          }
        }
      }
    }
    out += "]}";
  }
  out += "]";
  return out;
}

void OpenAutofillSettings() {
  RegisterNativeMessagingHost();
  // Open the browser extensions page so the user can install/enable OpenKey.
  if (reinterpret_cast<INT_PTR>(ShellExecuteW(
          nullptr, L"open", L"msedge.exe", L"edge://extensions/", nullptr,
          SW_SHOWNORMAL)) > 32) {
    return;
  }
  if (reinterpret_cast<INT_PTR>(ShellExecuteW(
          nullptr, L"open", L"chrome.exe", L"chrome://extensions/", nullptr,
          SW_SHOWNORMAL)) > 32) {
    return;
  }
  if (reinterpret_cast<INT_PTR>(ShellExecuteW(
          nullptr, L"open", L"firefox.exe", L"about:addons", nullptr,
          SW_SHOWNORMAL)) > 32) {
    return;
  }
  // Last resort: show the native-messaging registration folder.
  ShellExecuteW(nullptr, L"open", LocalOpenKeyDir().c_str(), nullptr, nullptr,
                SW_SHOWNORMAL);
}

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> g_channel;

}  // namespace

void SetupAutofillChannel(flutter::BinaryMessenger* messenger) {
  g_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "openkey/autofill",
          &flutter::StandardMethodCodec::GetInstance());

  g_channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        const auto& method = call.method_name();
        if (method == "syncCredentials") {
          const auto* args =
              std::get_if<flutter::EncodableList>(call.arguments());
          if (!args) {
            result->Error("bad_args", "Expected list");
            return;
          }
          WriteCredentialsJson(CredentialsToJson(*args));
          RegisterNativeMessagingHost();
          result->Success(flutter::EncodableValue(true));
        } else if (method == "clearCredentials") {
          ClearCredentialsJson();
          result->Success(flutter::EncodableValue(true));
        } else if (method == "isAutofillEnabled") {
          result->Success(
              flutter::EncodableValue(IsNativeMessagingRegistered()));
        } else if (method == "openAutofillSettings" ||
                   method == "setAutofillEnabled") {
          OpenAutofillSettings();
          result->Success(flutter::EncodableValue(true));
        } else if (method == "takePendingSave" || method == "takePendingUnlock") {
          result->Success(flutter::EncodableValue());
        } else {
          result->NotImplemented();
        }
      });
}
