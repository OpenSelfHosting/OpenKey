# openkey_shared

The shared Flutter package for the official OpenKey editions.

## Shared APIs

The package currently owns dependency-light code that must behave identically
in both apps:

- `Either<L, R>`, `Left`, and `Right` for typed success/failure results.
- `passwordStrengthScore` and `isWeakPassword` for the vault password
  strength heuristic.
- `FeatureAccess` and the edition capability identifiers used by host apps.

Import the public API through:

```dart
import 'package:openkey_shared/openkey_shared.dart';
```

The existing app-local paths remain as thin re-exports for source compatibility.
The implementation lives in this package only, so fixes to the shared logic are
picked up by both editions after their dependency is updated.

## Ownership boundary

This package owns implementation that must stay consistent between editions:
shared domain primitives, cryptography, vault models, persistence, auth/sync
domain logic, and reusable services or UI as those modules are migrated.

The host applications own product-specific composition:

- application entry points, branding, signing, and store configuration;
- free-edition and subscription-backed feature-access policies;
- paywalls, purchases, restore flows, and billing SDK integrations;
- private Pro-only presentation and commercial configuration.

Do not put purchase SDKs, store product IDs, API secrets, signing files, or
subscription credentials in this package.

## Migration safety

The next extraction stages must preserve existing encryption algorithms and
ciphertext formats, key-derivation parameters, Drift schemas and migrations,
secure-storage key names, backup compatibility, and server sync protocols.
Move these components only with regression tests against existing user data.
