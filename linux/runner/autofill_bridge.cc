#include "autofill_bridge.h"

#include <gio/gio.h>
#include <glib.h>
#include <unistd.h>

#include <fstream>
#include <iterator>
#include <string>
#include <vector>

namespace {

constexpr const char* kHostName = "com.openselfhosting.openkey";

std::string HomeDir() {
  const char* home = getenv("HOME");
  return home ? home : "";
}

std::string OpenKeyDataDir() {
  const char* xdg = getenv("XDG_DATA_HOME");
  std::string base;
  if (xdg && xdg[0] != '\0') {
    base = xdg;
  } else {
    base = HomeDir() + "/.local/share";
  }
  const std::string dir = base + "/OpenKey";
  g_mkdir_with_parents(dir.c_str(), 0700);
  return dir;
}

std::string ConfigDir() {
  const char* xdg = getenv("XDG_CONFIG_HOME");
  if (xdg && xdg[0] != '\0') return xdg;
  return HomeDir() + "/.config";
}

std::string NativeHostExePath() {
  char path[4096] = {};
  const ssize_t len = readlink("/proc/self/exe", path, sizeof(path) - 1);
  if (len <= 0) return {};
  path[len] = '\0';
  std::string exe(path);
  const auto slash = exe.find_last_of('/');
  if (slash == std::string::npos) return {};
  return exe.substr(0, slash + 1) + "openkey_native_host";
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
  const std::string path = OpenKeyDataDir() + "/chrome_extension_id.txt";
  std::ifstream in(path, std::ios::binary);
  if (!in) return {};
  return std::string((std::istreambuf_iterator<char>(in)),
                     std::istreambuf_iterator<char>());
}

std::vector<std::string> SplitChromeExtensionIds(const std::string& raw) {
  std::vector<std::string> ids;
  std::string cur;
  auto flush = [&]() {
    std::string id = cur;
    while (!id.empty() &&
           (id.front() == ' ' || id.front() == '\t' || id.front() == '\r' ||
            id.front() == '\n')) {
      id.erase(id.begin());
    }
    while (!id.empty() &&
           (id.back() == ' ' || id.back() == '\t' || id.back() == '\r' ||
            id.back() == '\n' || id.back() == '/')) {
      id.pop_back();
    }
    const char* prefix = "chrome-extension://";
    if (id.size() > 19 &&
        id.compare(0, 19, prefix) == 0) {
      id = id.substr(19);
      auto slash = id.find('/');
      if (slash != std::string::npos) id = id.substr(0, slash);
    }
    bool ok = id.size() == 32;
    for (char& c : id) {
      if (c >= 'A' && c <= 'P') c = static_cast<char>(c - 'A' + 'a');
      if (c < 'a' || c > 'p') ok = false;
    }
    if (ok) {
      bool dup = false;
      for (const auto& existing : ids) {
        if (existing == id) dup = true;
      }
      if (!dup) ids.push_back(id);
    }
    cur.clear();
  };
  for (char c : raw) {
    if (c == ',' || c == ';' || c == ' ' || c == '\n' || c == '\r' || c == '\t') {
      flush();
    } else {
      cur.push_back(c);
    }
  }
  flush();
  return ids;
}

std::string BuildManifest(const std::string& host_exe) {
  const std::vector<std::string> ids =
      SplitChromeExtensionIds(ReadChromeExtensionId());
  std::string origins_block = "  \"allowed_origins\": [\n";
  for (size_t i = 0; i < ids.size(); ++i) {
    origins_block += "    \"chrome-extension://" + EscapeJson(ids[i]) + "/\"";
    if (i + 1 < ids.size()) origins_block += ",";
    origins_block += "\n";
  }
  origins_block += "  ],\n";

  return std::string("{\n") +
         "  \"name\": \"" + kHostName + "\",\n"
         "  \"description\": \"OpenKey native messaging host\",\n"
         "  \"path\": \"" +
         EscapeJson(host_exe) +
         "\",\n"
         "  \"type\": \"stdio\",\n" +
         origins_block +
         "  \"allowed_extensions\": [\n"
         "    \"openkey@openselfhosting.local\"\n"
         "  ]\n"
         "}\n";
}

bool WriteFile(const std::string& path, const std::string& body) {
  const auto slash = path.find_last_of('/');
  if (slash != std::string::npos) {
    g_mkdir_with_parents(path.substr(0, slash).c_str(), 0700);
  }
  std::ofstream out(path, std::ios::binary | std::ios::trunc);
  if (!out) return false;
  out.write(body.data(), static_cast<std::streamsize>(body.size()));
  return static_cast<bool>(out);
}

bool IsNativeMessagingRegistered() {
  const std::string config = ConfigDir();
  const std::vector<std::string> candidates = {
      config + "/google-chrome/NativeMessagingHosts/" + kHostName + ".json",
      config + "/chromium/NativeMessagingHosts/" + kHostName + ".json",
      config + "/microsoft-edge/NativeMessagingHosts/" + kHostName + ".json",
      HomeDir() + "/.mozilla/native-messaging-hosts/" + kHostName + ".json",
      OpenKeyDataDir() + "/" + kHostName + ".json",
  };
  for (const auto& path : candidates) {
    if (access(path.c_str(), R_OK) == 0) return true;
  }
  return false;
}

bool RegisterNativeMessagingHost() {
  const std::string host = NativeHostExePath();
  if (host.empty() || access(host.c_str(), X_OK) != 0) {
    return false;
  }
  const auto ids = SplitChromeExtensionIds(ReadChromeExtensionId());
  // Don't clobber a Dart-written manifest that already lists Chrome origins.
  if (ids.empty() && IsNativeMessagingRegistered()) {
    return true;
  }

  const std::string body = BuildManifest(host);
  // Keep a canonical copy under XDG data.
  WriteFile(OpenKeyDataDir() + "/" + kHostName + ".json", body);

  const std::string config = ConfigDir();
  const std::vector<std::string> chromium_dirs = {
      config + "/google-chrome/NativeMessagingHosts",
      config + "/google-chrome-beta/NativeMessagingHosts",
      config + "/google-chrome-unstable/NativeMessagingHosts",
      config + "/chromium/NativeMessagingHosts",
      config + "/microsoft-edge/NativeMessagingHosts",
      config + "/microsoft-edge-beta/NativeMessagingHosts",
      config + "/BraveSoftware/Brave-Browser/NativeMessagingHosts",
      config + "/vivaldi/NativeMessagingHosts",
  };

  bool any = false;
  const std::string filename = std::string(kHostName) + ".json";
  for (const auto& dir : chromium_dirs) {
    if (WriteFile(dir + "/" + filename, body)) any = true;
  }

  // Firefox / LibreWolf use a different directory and allowed_extensions.
  const std::vector<std::string> firefox_dirs = {
      HomeDir() + "/.mozilla/native-messaging-hosts",
      HomeDir() + "/.librewolf/native-messaging-hosts",
      config + "/mozilla/native-messaging-hosts",
  };
  for (const auto& dir : firefox_dirs) {
    if (WriteFile(dir + "/" + filename, body)) any = true;
  }
  return any;
}

void WriteCredentialsJson(const std::string& json) {
  WriteFile(OpenKeyDataDir() + "/openkey-autofill-creds.json", json);
}

void ClearCredentialsJson() {
  unlink((OpenKeyDataDir() + "/openkey-autofill-creds.json").c_str());
}

std::string EscapeForJsonString(const gchar* value) {
  return EscapeJson(value ? value : "");
}

std::string CredentialsToJson(FlValue* list) {
  if (!list || fl_value_get_type(list) != FL_VALUE_TYPE_LIST) return "[]";
  std::string out = "[";
  bool first_item = true;
  const size_t count = fl_value_get_length(list);
  for (size_t i = 0; i < count; ++i) {
    FlValue* item = fl_value_get_list_value(list, i);
    if (fl_value_get_type(item) != FL_VALUE_TYPE_MAP) continue;
    if (!first_item) out += ",";
    first_item = false;

    auto get_string = [&](const char* key) -> std::string {
      FlValue* v = fl_value_lookup_string(item, key);
      if (!v || fl_value_get_type(v) != FL_VALUE_TYPE_STRING) return {};
      return EscapeForJsonString(fl_value_get_string(v));
    };

    out += "{\"uuid\":\"" + get_string("uuid") + "\",";
    out += "\"title\":\"" + get_string("title") + "\",";
    out += "\"username\":\"" + get_string("username") + "\",";
    out += "\"password\":\"" + get_string("password") + "\",";
    out += "\"urls\":[";

    FlValue* urls = fl_value_lookup_string(item, "urls");
    bool first_url = true;
    if (urls && fl_value_get_type(urls) == FL_VALUE_TYPE_LIST) {
      const size_t n = fl_value_get_length(urls);
      for (size_t u = 0; u < n; ++u) {
        FlValue* url = fl_value_get_list_value(urls, u);
        if (!url || fl_value_get_type(url) != FL_VALUE_TYPE_STRING) continue;
        if (!first_url) out += ",";
        first_url = false;
        out += "\"" + EscapeForJsonString(fl_value_get_string(url)) + "\"";
      }
    }
    out += "]}";
  }
  out += "]";
  return out;
}

void OpenAutofillSettings() {
  RegisterNativeMessagingHost();
  const char* browsers[] = {
      "microsoft-edge",
      "google-chrome",
      "chromium",
      "firefox",
      "brave-browser",
  };
  for (const char* browser : browsers) {
    gchar* path = g_find_program_in_path(browser);
    if (!path) continue;
    const char* page = g_str_has_prefix(browser, "firefox") ? "about:addons"
                                                            : "chrome://extensions";
    gchar* argv[] = {path, g_strdup(page), nullptr};
    g_spawn_async(nullptr, argv, nullptr, G_SPAWN_SEARCH_PATH, nullptr, nullptr,
                  nullptr, nullptr);
    g_free(argv[1]);
    g_free(path);
    return;
  }
  // Fallback: open the OpenKey data folder in the file manager.
  const std::string dir = OpenKeyDataDir();
  gchar* argv[] = {g_strdup("xdg-open"), g_strdup(dir.c_str()), nullptr};
  g_spawn_async(nullptr, argv, nullptr, G_SPAWN_SEARCH_PATH, nullptr, nullptr,
                nullptr, nullptr);
  g_free(argv[0]);
  g_free(argv[1]);
}

FlMethodChannel* g_channel = nullptr;

void method_call_cb(FlMethodChannel* /*channel*/, FlMethodCall* method_call,
                    gpointer /*user_data*/) {
  const gchar* method = fl_method_call_get_name(method_call);
  g_autoptr(FlMethodResponse) response = nullptr;

  if (g_strcmp0(method, "syncCredentials") == 0) {
    FlValue* args = fl_method_call_get_args(method_call);
    if (args) {
      WriteCredentialsJson(CredentialsToJson(args));
    }
    RegisterNativeMessagingHost();
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_bool(TRUE)));
  } else if (g_strcmp0(method, "clearCredentials") == 0) {
    ClearCredentialsJson();
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_bool(TRUE)));
  } else if (g_strcmp0(method, "isAutofillEnabled") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(
        fl_value_new_bool(IsNativeMessagingRegistered())));
  } else if (g_strcmp0(method, "openAutofillSettings") == 0 ||
             g_strcmp0(method, "setAutofillEnabled") == 0) {
    OpenAutofillSettings();
    response = FL_METHOD_RESPONSE(
        fl_method_success_response_new(fl_value_new_bool(TRUE)));
  } else if (g_strcmp0(method, "takePendingSave") == 0 ||
             g_strcmp0(method, "takePendingUnlock") == 0) {
    response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(method_call, response, &error)) {
    g_warning("Failed to send method response: %s", error->message);
  }
}

}  // namespace

void setup_autofill_channel(FlView* view) {
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_channel = fl_method_channel_new(
      fl_engine_get_binary_messenger(fl_view_get_engine(view)),
      "openkey/autofill", FL_METHOD_CODEC(codec));
  // Keep the channel alive for the process lifetime.
  g_object_ref_sink(g_channel);
  fl_method_channel_set_method_call_handler(g_channel, method_call_cb, nullptr,
                                            nullptr);
}
