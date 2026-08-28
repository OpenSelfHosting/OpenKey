# Sync API (ciphertext only)

The reference implementation is [OpenKey_server](https://github.com/OpenSelfHosting/OpenKey_server) (FastAPI + PostgreSQL). Interactive OpenAPI: `/docs` on a running server.

## Trust

The server is **untrusted for confidentiality**. It may store, delete, or withhold blobs. It must not be able to decrypt vault data.

It **is** trusted for availability and for comparing `auth_hash` at login.

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

Master password and vault-key plaintext are never stored.

## Vault rows

Collections and entries are opaque ciphertext plus metadata (`uuid`, `revision`, tombstones). Org names, share payloads, and attachment bytes follow the same rule: encrypted on the client.

Last-write-wins uses per-item `revision`. Concurrent edits can overwrite; this is not a CRDT.

## Auth tokens

- Short-lived access JWTs (HS256, server `JWT_SECRET`)
- Opaque refresh tokens, hashed at rest, rotated on use
- Auth endpoints are rate-limited per client IP

## CORS

Production `CORS_ORIGINS` must be an explicit list. Never `*`. Browser-extension origins may be allowed separately when the extension talks to the API in standalone mode.

## Official vs open clients

Any client that implements [crypto.md](./crypto.md) and this API can sync. The **official app** is a proprietary client of this protocol. The extension (standalone mode) and CLI (session mode) are open implementations.
