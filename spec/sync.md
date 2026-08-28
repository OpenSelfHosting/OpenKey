# Sync API (ciphertext only)

The reference implementation is [OpenKey_server](https://github.com/OpenSelfHosting/OpenKey_server) (FastAPI + PostgreSQL). Interactive OpenAPI: `/docs` on a running server. Operator guide: [Install the server](https://openkey.openselfhosting.com/guide/server).

## Trust

The server is **untrusted for confidentiality**. It may store, delete, or withhold blobs. It must not be able to decrypt vault data.

It **is** trusted for availability and for comparing `auth_hash` at login.

Nearby LAN sync between devices is peer-to-peer. It does **not** use this API.

## Account material (still not plaintext vault)

Stored per user, among other fields:

| Field | Meaning |
|-------|---------|
| `email` | Account identifier |
| `salt` | Argon2id salt |
| `kdf_params` | Argon2id settings JSON |
| `auth_hash` | HMAC auth hash (see [crypto.md](./crypto.md)) |
| `encrypted_vault_key` | Vault key wrapped with the master key |
| `public_key` | Optional X25519 public key for shares / orgs |
| `encrypted_private_key` | Optional wrapped identity private key |

Master password and vault-key plaintext are never stored.

## Auth

Auth endpoints are rate-limited per client IP. Register / login / refresh return an access JWT (HS256, server `JWT_SECRET`), an opaque refresh token (SHA-256 hashed at rest, rotated on use), `user_id`, and `expires_in`. Reuse of an already-rotated refresh token revokes **all** refresh tokens for that user.

| Method | Path | Notes |
|--------|------|--------|
| `POST` | `/auth/register` | `email`, `auth_hash`, `encrypted_vault_key`, `kdf_params`, `salt`, optional `public_key` |
| `POST` | `/auth/prelogin` | `email` → `salt`, `kdf_params` so a new client can derive `auth_hash` |
| `POST` | `/auth/login` | `email`, `auth_hash` |
| `POST` | `/auth/refresh` | `refresh_token` → new token pair |
| `POST` | `/auth/logout` | Revoke a refresh token |
| `POST` | `/auth/delete` | Bearer + `auth_hash` — permanently deletes the account and server-side vault data |
| `GET` | `/auth/me` | Unlock bootstrap: salt, wrapped vault key, KDF params, identity keys |
| `PATCH` | `/auth/me/keys` | `public_key`, `encrypted_private_key` |
| `POST` | `/auth/rekey` | After a master-password change: new `auth_hash` + wrapped vault key; entries are not re-encrypted |
| `POST` | `/auth/lookup-public-key` | `email` → peer `public_key` for sealed boxes |

## Vault rows

Collections and entries are opaque ciphertext plus metadata (`uuid`, `revision`, tombstones). Nested folders use `parent_uuid` (null = top-level). Org names, share payloads, and attachment bytes follow the same rule: encrypted on the client.

Reserved personal-vault collection ids (ciphertext still syncs like any other collection): `__wallets__`, `__crypto_wallets__`, `__dev_secrets__`. See [vault.md](./vault.md).

Last-write-wins uses per-item `revision`. Concurrent edits can overwrite; this is not a CRDT.

| Method | Path | Notes |
|--------|------|--------|
| `GET`/`POST`/`PATCH`/`DELETE` | `/collections`, `/collections/{uuid}` | `encrypted_name`, optional `icon`, `color`, `parent_uuid`, `sort_order`, `revision` |
| `GET`/`POST`/`PATCH`/`DELETE` | `/entries`, `/entries/{uuid}` | `encrypted_payload`, optional `collection_uuid`, `revision` |

Deletes are soft. Tombstones sync to peers.

## Attachments

Ciphertext only. Max size **20 MB**. Prefer multipart upload; batch `/sync` may still carry base64 blobs for offline catch-up.

| Method | Path | Notes |
|--------|------|--------|
| `GET` | `/attachments` | Metadata only |
| `POST` | `/attachments` | Multipart: `uuid`, `entry_uuid`, `filename`, `size_bytes`, file field `file` |
| `GET` | `/attachments/{uuid}/content` | Stream encrypted bytes |
| `DELETE` | `/attachments/{uuid}` | Soft delete |

## Sync

```http
POST /sync
```

Pushes local collections, entries, and attachments (last-write-wins by per-item `revision`) and returns rows whose `updated_at` is newer than `since_revision`. The cursor is unix microseconds of `updated_at` — pass `0` for a full pull. Org memberships and shares use their own endpoints (not included in this batch).

The CLI (`openkey sync`) and the browser extension standalone vault use this same contract. Native-bridge mode does not call the API.

## Orgs, invites, and shares

Org display names are `encrypted_name`. Members receive a per-user `wrapped_org_key`. Item shares wrap an item key for the recipient; **entry shares snapshot** `encrypted_payload` at create time (later owner edits are not pushed). Status: `pending` → `accepted` / `revoked`.

Clients wrap keys for another user’s X25519 public key with sealed boxes ([crypto.md](./crypto.md)). The server stores only opaque blobs.

## CORS

Production `CORS_ORIGINS` must be an explicit list. Never `*`. Browser-extension origins (`chrome-extension://`, `moz-extension://`) may be allowed separately when the extension talks to the API in standalone mode (`CORS_ALLOW_BROWSER_EXTENSIONS` on the reference server).

## Official vs open clients

Any client that implements [crypto.md](./crypto.md), [vault.md](./vault.md), and this API can sync. The **official app** is a proprietary client of this protocol. The extension (standalone mode) and CLI (session mode) are open implementations.
