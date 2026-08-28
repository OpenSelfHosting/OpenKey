# Product screenshots

Replace each placeholder PNG with a capture from the official OpenKey app. **Keep the filename** so [README.md](../../README.md) does not need to change.

Do not photograph real credentials. Use a demo vault.

Current files were generated from the app widgets with demo data:

```bash
cd ../../../OpenKey_app
GENERATE_SCREENSHOTS=1 flutter test test/screenshots/readme_screenshots_test.dart
```

`05-autofill.png` is a composite of the extension picker on a login form (not a live OS Autofill sheet). Swap any file after you review.

| File | Slot in README | Suggested capture |
|------|----------------|-------------------|
| `01-desktop.png` | Hero, left | Unlocked vault on macOS, Windows, or Linux. **1600×1000** (or 16:10). Dark theme preferred. |
| `02-mobile.png` | Hero, right | Unlocked vault on Android or iOS. Portrait, **~9:19.5**. Export from the device, not a window screenshot. |
| `03-vault.png` | Gallery | Collections list with a few logins visible. **1440×900**. |
| `04-entry.png` | Gallery | Open login showing username, password (masked), and TOTP. **1440×900**. |
| `05-autofill.png` | Gallery | System Autofill sheet or the browser extension filling a form. **1440×900**. |
| `06-sync.png` | Gallery | **Settings → Data → Self-hosted server** with a server URL entered. **1440×900**. |

## How to drop files in

1. Capture the screen on the device or desktop.
2. Crop to the app UI. Leave a small margin; avoid desktop wallpaper and status-bar clutter where you can.
3. Overwrite the matching file in this folder.
4. Refresh the README preview.

App icon in the README header is the official mark from `OpenKey_app/assets/icon/` (`icon-rounded.png`).

To restore empty screenshot slots (this overwrites any captures already in this folder):

```bash
python3 docs/generate_assets.py
```
