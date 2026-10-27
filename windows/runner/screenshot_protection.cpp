#include "screenshot_protection.h"

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace {

#ifndef WDA_NONE
#define WDA_NONE 0x00000000
#endif
#ifndef WDA_EXCLUDEFROMCAPTURE
#define WDA_EXCLUDEFROMCAPTURE 0x00000011
#endif

HWND g_window = nullptr;
std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> g_channel;

bool SetCaptureBlocked(bool blocked) {
  if (g_window == nullptr) {
    return false;
  }
  const DWORD affinity = blocked ? WDA_EXCLUDEFROMCAPTURE : WDA_NONE;
  return ::SetWindowDisplayAffinity(g_window, affinity) == TRUE;
}

}  // namespace

void SetupScreenshotProtectionChannel(flutter::BinaryMessenger* messenger,
                                      HWND window) {
  g_window = window;
  g_channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          messenger, "openkey/screenshot_protection",
          &flutter::StandardMethodCodec::GetInstance());

  g_channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        const auto& method = call.method_name();
        if (method == "screenshotOff") {
          result->Success(flutter::EncodableValue(SetCaptureBlocked(true)));
        } else if (method == "screenshotOn") {
          result->Success(flutter::EncodableValue(SetCaptureBlocked(false)));
        } else {
          result->NotImplemented();
        }
      });
}
