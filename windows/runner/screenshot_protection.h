#ifndef RUNNER_SCREENSHOT_PROTECTION_H_
#define RUNNER_SCREENSHOT_PROTECTION_H_

#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>

#include <windows.h>

namespace flutter {
class BinaryMessenger;
}

// Registers openkey/screenshot_protection using SetWindowDisplayAffinity.
void SetupScreenshotProtectionChannel(flutter::BinaryMessenger* messenger,
                                      HWND window);

#endif  // RUNNER_SCREENSHOT_PROTECTION_H_
