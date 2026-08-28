# Cryptography

OpenKey is zero-knowledge toward the optional sync server: the server never receives the master password and never sees vault plaintext.

## Key derivation

Password bytes for Argon2id:

```text
utf8( trim(email).toLowerCase() + ":" + master_password )
```

| Parameter | Value |
|-----------|--------|
| Algorithm | Argon2id |
| Salt | 16 random bytes (stored on the server, not secret) |
| Memory | 65536 KiB |
| Iterations | 3 |
| Parallelism | 4 |
| Hash length | 32 |
| Output | 32-byte **master key** |

KDF parameters are stored as JSON on the account (`algorithm`, `memory`, `iterations`, `parallelism`, `hashLength`) so clients can evolve settings later. Default JSON matches the table above (`algorithm`: `argon2id`).

## Auth hash

```text
auth_hash = base64url_nopad( HMAC-SHA256(master_key, "openkey-auth") )
```

`auth_hash` is sent to the server for register / login. It is **not** the vault key. The master password is never sent.

## Vault key

- 32 random bytes generated on the client.
- Wrapped with AES-256-GCM under the master key (`encrypted_vault_key` on the account).
- All collection names and entry payloads are encrypted with the vault key.

Local DB encryption key (official app):

```text
db_key = HMAC-SHA256(vault_key, "openkey-db")
```

## AES-256-GCM wire format

Unpadded **base64url** of:

```text
nonce (12 bytes) || ciphertext || tag (16 bytes)
```

Used for wrapped vault keys and for each encrypted field / payload blob.

## Encoding

- **base64url**, padding `=` stripped, matching the extension helper `toB64Url`.
- Decoders accept padded or unpadded base64 / base64url.

## Sealed boxes (orgs / shares)

Version byte `0x01`. Unpadded base64url of:

```text
0x01 || ephemeral_x25519_public (32) || nonce (12) || ciphertext || tag (16)
```

AES-GCM key:

```text
SHA-256( utf8("openkey-seal-v1") || X25519_shared_secret )
```

Used so one user can wrap keys for another user’s X25519 public key without sharing the vault key in plaintext.

## What never leaves the client

- Master password
- Master key
- Vault key plaintext
- Decrypted collection names and entry JSON
