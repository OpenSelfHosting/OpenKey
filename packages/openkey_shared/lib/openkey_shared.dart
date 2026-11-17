/// Public API for functionality shared by OpenKey editions.
///
/// The package starts with stable cross-edition contracts. Domain and UI
/// modules will be moved here in focused follow-up changes after both app
/// variants are compared and their platform-specific dependencies are mapped.
library;

export 'src/feature_access/feature_access.dart';
export 'src/feature_access/free_edition_feature_access.dart';
export 'src/feature_access/open_key_feature.dart';
