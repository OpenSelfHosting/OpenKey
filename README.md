# OpenKey

Self-hosted, end-to-end encrypted password manager by [OpenSelfHosting](https://github.com/OpenSelfHosting).

Clients encrypt vault data on the device. The optional sync server stores **ciphertext only** — the master password never leaves the client.

**Protocol is open. The official app is not.** Audit crypto and self-host from this repo and the open packages. Install the official client from [Releases](https://github.com/OpenSelfHosting/OpenKey/releases) or the [docs download page](https://openselfhosting.com/guide/download).

## What you can open and audit

| Piece | Repo | License |
|-------|------|---------|
| Protocol spec (KDF, vault payload, sync) | [`spec/`](./spec/) in this repo | MIT |
| Sync server | [OpenKey_server](https://github.com/OpenSelfHosting/OpenKey_server) | MIT |
| Browser extension | [OpenKey_extension](https://github.com/OpenSelfHosting/OpenKey_extension) | MIT |
| Developer CLI | [OpenKey_cli](https://github.com/OpenSelfHosting/OpenKey_cli) | MIT |
| Documentation site | [OpenKey_docs](https://github.com/OpenSelfHosting/OpenKey_docs) | MIT |

The official **OpenKey app** (Android, iOS, macOS, Linux, Windows) is proprietary. Source is not published. Binaries for that client are attached to **this** repository’s GitHub Releases. Use of the app is under the [Terms of Service](https://openselfhosting.com/terms). Subscriptions (**OpenKey Pro**) are sold through the app stores (RevenueCat).

## Download the app

- **GitHub Releases** (this repo): Linux packages, Android APK/AAB, and desktop installers as they are published
- **Stores** (when listed): Google Play, App Store, Mac App Store, Microsoft Store, Flathub, Snap — see [Download](https://openselfhosting.com/guide/download)

Do not expect a public `flutter build` of the official client.

## Self-host the sync server

The server is optional. Personal vaults work offline. Sync across your devices needs an instance you control.

```bash
git clone https://github.com/OpenSelfHosting/OpenKey_server.git
cd OpenKey_server
cp .env.example .env
openssl rand -hex 32   # paste into JWT_SECRET in .env
docker compose up --build -d
```

API: `http://localhost:8000` · OpenAPI: `/docs` · Health: `/health`

Then in the official app: **Settings → Data → Self-hosted server** → that URL → register or log in → sync.

Production: HTTPS in front of the API, unique `JWT_SECRET` (min 32 characters), explicit `CORS_ORIGINS` (never `*`). Full guide: [Install the server](https://openselfhosting.com/guide/server).

## Zero-knowledge (short)

1. `Argon2id(normalized_email + master_password, salt)` → master key
2. Master key → `auth_hash` (HMAC, sent to the server) and wraps the vault key
3. Vault key encrypts collection names and entry payloads (**AES-256-GCM**)
4. The server stores salt, KDF params, wrapped vault key, and opaque ciphertext — not the master password

Details: [`spec/crypto.md`](./spec/crypto.md) · [Security](https://openselfhosting.com/guide/security)

## Browser extension and CLI

Open source. They speak the same protocol as the official app (standalone vault + optional native bridge to the **unlocked** desktop app).

```bash
# Extension
git clone https://github.com/OpenSelfHosting/OpenKey_extension.git
cd OpenKey_extension && npm install && npm run build
# load dist/ unpacked in chrome://extensions or about:debugging

# CLI (npm)
npm install -g openkey-cli
```

Guides: [Extension](https://openselfhosting.com/guide/extension) · [CLI](https://openselfhosting.com/guide/cli)

## Security

Report vulnerabilities **privately** to **security@openselfhosting.com** — do not open a public issue for exploitable bugs. See [SECURITY.md](./SECURITY.md).

## Maintainer: after you review this locally

These steps are not done from the working tree; they need your GitHub / RevenueCat access:

1. Add secrets on the **private** app repo `OpenSelfHosting/OpenKey_app`:
   - `REVENUECAT_ANDROID_KEY`, `REVENUECAT_IOS_KEY`, `REVENUECAT_MACOS_KEY`
   - `PUBLIC_RELEASE_TOKEN` — PAT with `contents:write` on **this** public repo only
2. Make `OpenKey_app` private: `gh repo edit OpenSelfHosting/OpenKey_app --visibility private`
3. Rotate the Android RevenueCat public SDK key if it was ever committed to a public git history
4. Push this repo, then server / extension / CLI / docs
5. Tag a release on `OpenKey_app` (`v*`) so CI uploads binaries here

Step-by-step (Arabic): `OpenKey_app/docs/MANUAL_TASKS.md` section 0.

## License

Documentation and spec in this repository: [MIT](./LICENSE). Official app source: proprietary (separate repository).
