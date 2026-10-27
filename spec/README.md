# OpenKey protocol spec

This folder documents the OpenKey protocol: how keys are derived, how vault items are encrypted, and what the sync server is allowed to see. The official Flutter app in the parent repository and the other OpenKey clients implement this contract.

The app and protocol documentation in this repository are licensed under the [MIT License](../LICENSE). Independent implementations, including the [browser extension](https://github.com/OpenSelfHosting/OpenKey_extension) and [CLI](https://github.com/OpenSelfHosting/OpenKey_cli), also follow this spec. Product site: [openkey.openselfhosting.com](https://openkey.openselfhosting.com).

| Document | Contents |
|----------|----------|
| [crypto.md](./crypto.md) | Argon2id, AES-256-GCM, auth hash, vault-key wrap, sealed boxes |
| [vault.md](./vault.md) | Decrypted JSON payloads (logins, cards, crypto wallets, secrets, attachments) |
| [sync.md](./sync.md) | Ciphertext-only API, what the server stores |

Normative behavior also lives in the MIT-licensed TypeScript crypto used by the extension and CLI. If a published client disagrees with this spec, treat it as a bug and report it to **security@openselfhosting.com**.
