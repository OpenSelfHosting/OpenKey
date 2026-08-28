# Vault payloads

After AES-GCM decryption, each vault **entry** is JSON. Collection **names** are encrypted separately; reserved namespaces below are collection ids, not display names.

## Reserved collection ids

These ids are not shown as normal password folders. Ciphertext still syncs like any other collection.

| Id | Contents |
|----|----------|
| `__wallets__` | Payment cards (`type: card`) |
| `__crypto_wallets__` | Crypto wallets (`type: crypto`) |
| `__dev_secrets__` | Developer secrets (`type: secret`) |

Logins live in user-created collections (or the vault root). They have **no** `type` field, or are treated as logins when `type` is absent.

## Login (password entry)

Typical decrypted object:

```json
{
  "title": "Example",
  "username": "user@example.com",
  "password": "…",
  "urls": ["https://example.com"],
  "notes": "",
  "tags": ["work"],
  "fields": [],
  "fieldOrder": [],
  "icon": "",
  "totp": {},
  "attachments": [],
  "passkey": {}
}
```

Optional keys may be omitted when empty. `totp` / `passkey` / `attachments` / custom `fields` use the shapes implemented by the official app and mirrored in the [browser extension](https://github.com/OpenSelfHosting/OpenKey_extension) TypeScript types.

## Payment card

```json
{
  "type": "card",
  "name": "Personal",
  "holder": "",
  "number": "",
  "expiry": "",
  "cvc": "",
  "brand": "visa",
  "notes": "",
  "bank": ""
}
```

`bank` is omitted when blank.

## Crypto wallet

```json
{
  "type": "crypto",
  "name": "",
  "network": "bitcoin",
  "address": "",
  "privateKey": "",
  "seedPhrase": "",
  "notes": "",
  "folder": ""
}
```

## Developer secret

```json
{
  "type": "secret",
  "name": "",
  "kind": "apiToken",
  "username": "",
  "host": "",
  "publicKey": "",
  "secret": "",
  "passphrase": "",
  "notes": "",
  "device": ""
}
```

`kind` is one of `apiToken`, `sshKey`, `envSnippet`, `other`.

## Sync metadata (not inside the payload)

Each row on the server has a client-generated `uuid`, optional `collection_uuid`, integer `revision` (last-write-wins), and opaque `encrypted_payload` (AES-GCM of the JSON above). Nested collections use `parent_uuid` on the collection row (not inside this JSON). Soft-deleted items remain as tombstones until peers sync.
