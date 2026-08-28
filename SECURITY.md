# Security Policy

## Reporting a vulnerability

If you believe you have found a security issue in OpenKey (protocol, server, extension, CLI, docs, or the official app), report it **privately**.

**Do not** open a public GitHub issue for exploitable vulnerabilities.

- Email: **security@openselfhosting.com**
- Or open a **private** security advisory on the relevant repository under [OpenSelfHosting](https://github.com/OpenSelfHosting)

Please include:

1. Affected piece (`OpenKey_server`, `OpenKey_extension`, `OpenKey_cli`, official app binaries, protocol spec, …)
2. Version / git tag / commit if known
3. Steps to reproduce
4. Impact (ciphertext disclosure, auth bypass, local privilege, …)

We aim to acknowledge reports within **7 days** and to ship a fix or mitigation for confirmed issues as quickly as practical.

## Scope

In scope:

- Cryptographic design flaws that weaken zero-knowledge guarantees (see [`spec/`](./spec/))
- Authentication / authorization bypass on the sync API
- Plaintext vault leakage from the extension, native messaging bridge, or CLI beyond intentional fill/save flows
- Remote code execution or privilege escalation in supported **open** packages
- Issues in **official app binaries** distributed from this repo’s Releases (report privately; source is not public)

Out of scope (unless you can show a practical exploit chain):

- Denial of service against a self-hosted instance
- Phishing / social engineering of master passwords
- Compromised devices with an **unlocked** vault (the vault key is in memory by design)
- Issues that require physical access plus an unlocked session

## Security model (summary)

- The sync server stores **ciphertext only**. Master passwords and plaintext vault keys must never leave the client.
- Access JWTs are short-lived; refresh tokens are hashed at rest and rotated on use.
- Soft-deleted vault items remain as tombstones until peers sync; last-write-wins uses per-item `revision`.

Full threat model: [openkey_docs/guide/security.md](https://openselfhosting.com/guide/security) and [`spec/crypto.md`](./spec/crypto.md).
