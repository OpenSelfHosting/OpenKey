#ifndef RUNNER_AUTOFILL_BRIDGE_H_
#define RUNNER_AUTOFILL_BRIDGE_H_

#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>

#include <memory>

namespace flutter {
class BinaryMessenger;
}

// Registers the openkey/autofill MethodChannel for Windows browser Autofill
// via native messaging host registration.
void SetupAutofillChannel(flutter::BinaryMessenger* messenger);

#endif  // RUNNER_AUTOFILL_BRIDGE_H_
