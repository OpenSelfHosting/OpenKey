import 'feature_access.dart';
import 'open_key_feature.dart';

/// Default capability policy for the free OpenKey edition.
///
/// This policy intentionally contains only feature availability that is
/// explicitly documented by the public product. Additional limits or Pro
/// capabilities must be added after verification against both applications.
final class FreeEditionFeatureAccess implements FeatureAccess {
  /// Creates the default free-edition policy.
  const FreeEditionFeatureAccess();

  @override
  bool canUse(OpenKeyFeature feature) => switch (feature) {
    OpenKeyFeature.nearbyDeviceSync => false,
  };
}
