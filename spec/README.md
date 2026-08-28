# OpenKey protocol spec

This folder is the public contract for OpenKey: how keys are derived, how vault items are encrypted, and what the sync server is allowed to see.

It is **not** the official Flutter app. That client is proprietary. Independent implementations (the [browser extension](https://github.com/OpenSelfHosting/OpenKey_extension) and [CLI](https://github.com/OpenSelfHosting/OpenKey_cli)) follow this spec.

| Document | Contents |
|----------|----------|
| [crypto.md](./crypto.md) | Argon2id, AES-256-GCM, auth hash, vault-key wrap, sealed boxes |
| [vault.md](./vault.md) | Decrypted JSON payloads (logins, cards, crypto wallets, secrets) |
| [sync.md](./sync.md) | Ciphertext-only API, what the server stores |

Normative behavior also lives in the MIT-licensed TypeScript crypto used by the extension and CLI. If a published client disagrees with this spec, treat it as a bug and report it to **security@openselfhosting.com**.
