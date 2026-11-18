/// A capability that can have different availability by OpenKey edition.
///
/// Add identifiers here only when their product behavior and free/pro
/// availability are documented and verified in the application.
enum OpenKeyFeature {
  /// Direct peer-to-peer synchronization with nearby devices over the LAN.
  ///
  /// The public OpenKey product documentation identifies this as an OpenKey
  /// Pro capability.
  nearbyDeviceSync,
}
