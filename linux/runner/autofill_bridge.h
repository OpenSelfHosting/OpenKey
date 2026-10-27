#ifndef RUNNER_AUTOFILL_BRIDGE_H_
#define RUNNER_AUTOFILL_BRIDGE_H_

#include <flutter_linux/flutter_linux.h>

// Registers the openkey/autofill MethodChannel for Linux browser Autofill
// via native messaging host registration.
void setup_autofill_channel(FlView* view);

#endif  // RUNNER_AUTOFILL_BRIDGE_H_
