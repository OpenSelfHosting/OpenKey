import 'open_key_feature.dart';

/// Resolves edition-specific access to shared OpenKey capabilities.
///
/// Implementations belong to the host application:
/// - the open-source edition supplies its free-edition policy;
/// - the private commercial edition supplies a policy backed by its verified
///   subscription entitlement.
///
/// Keep billing SDKs, store product identifiers, purchase flows, and secrets
/// out of this package.
abstract interface class FeatureAccess {
  /// Whether the current installation can use [feature].
  bool canUse(OpenKeyFeature feature);
}
