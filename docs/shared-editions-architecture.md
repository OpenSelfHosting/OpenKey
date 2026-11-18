# OpenKey shared-edition architecture

## Goal

Maintain one implementation of the password manager while shipping two
product editions:

- **OpenKey** — the public, open-source edition.
- **OpenKey_app** — the private commercial edition with subscriptions and
  additional Pro capabilities.

The editions must not maintain independent copies of cryptography, vault
persistence, synchronization, or common UI.

## Package boundary

The public repository owns packages/openkey_shared. Both applications use
this package as their shared implementation.

The public app uses a local path dependency while developing in this
repository. The private app should consume a pinned tag/commit from the public
repository, never an unpinned moving branch.

## Edition-specific adapters

Shared code must not import a billing SDK. Instead it depends on the
FeatureAccess interface.

- The public application provides FreeEditionFeatureAccess.
- The private application provides a subscription-backed implementation
  populated from verified store entitlements.

Subscription screens, purchase/restore flows, billing products, and private
commercial configuration stay in the private application.

## Security and migration invariants

The extraction must preserve:

- existing encryption algorithms, KDF parameters, key wrapping, and
  ciphertext formats;
- Drift schema versions, migrations, and database file locations;
- secure-storage key names and account namespace behavior;
- backup/import/export compatibility;
- authentication and server synchronization protocols.

Never combine the package extraction with a database/schema migration unless
that migration is independently tested and explicitly required.

## Rollout

This foundation change introduces the package and capability contract only.
The source extraction and app wiring are follow-up changes. They require the
private app source to be available so the two codebases can be reconciled
before any shared implementation is removed.
