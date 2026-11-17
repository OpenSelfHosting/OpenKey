# openkey_shared

The shared Flutter package for OpenKey product editions.

## Current scope

This first extraction establishes the package boundary and a small, stable
contract for edition-specific feature access. It does **not** yet contain the
vault implementation or shared UI. Those modules must be moved in focused
steps after the private application can be inspected and compared.

## Ownership boundary

The package will own code that must behave identically in every edition:

- cryptography, key derivation, and vault encryption;
- vault models, database schema, migrations, and repositories;
- authentication and synchronization domain logic;
- reusable application services and shared UI components.

The host applications will own product-specific composition:

- application entry points, branding, signing, and store configuration;
- free-edition and subscription-backed feature access policies;
- paywalls, purchases, restore flows, and billing SDK integrations;
- private Pro-only product presentation and commercial configuration.

Do not put purchase SDKs, store product IDs, API secrets, signing files, or
subscription credentials in this package.

## Feature access

Host applications implement FeatureAccess and provide it through their
dependency-injection layer. Shared features should ask this abstraction
whether a capability is available rather than importing billing code or
checking the product edition directly.

The free policy currently denies nearbyDeviceSync, which public OpenKey
documentation identifies as an OpenKey Pro capability. Other gates must only
be added after their behavior is verified in both app repositories.

## Migration sequence

1. Compare the public and private app trees, dependency graphs, native
   integrations, and tests.
2. Extract pure Dart domain code first, preserving public APIs and serialized
   data formats.
3. Extract database/repository/service modules with migration and crypto
   regression tests.
4. Extract shared Flutter features and widgets after platform-specific
   adapters are separated.
5. Wire the open-source app to the package using a local path dependency.
6. Wire the private app to a pinned Git tag of this package and implement its
   subscription-backed FeatureAccess.
7. Remove duplicate source only after both editions build and pass regression
   tests on their supported platforms.

## Local development

From this directory, run flutter pub get, flutter analyze --fatal-infos, and
flutter test --reporter expanded.

The root application is not wired to this package in this foundation change.
That integration is intentionally deferred until the complete extraction and
both-edition regression suite are ready.
