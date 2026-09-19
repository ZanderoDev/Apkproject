# Absen PMR Puspa 5

Production-oriented Flutter attendance app for PMR Puspa 5.

## Features

- Local SQLite persistence with member and attendance records.
- Check-in/check-out with timestamps and daily dashboard summaries.
- Member search, create, edit, and delete.
- Attendance timeline and CSV export.
- Manual backup and restore to Android public `Documents/PMRPuspa5_Backup`.
- Material UI with PMR crimson theme, subtle glass cards, animations, and Lottie assets.
- Android builds for `armeabi-v7a` and `arm64-v8a`.

## Run locally

```bash
flutter pub get
flutter analyze
flutter build apk --split-per-abi
```

The generated APKs are in `build/app/outputs/flutter-apk/`.

## Backup behavior

Backups are JSON snapshots saved through Android's scoped-storage MediaStore API. On Android 10 and newer, the app writes to the public Documents collection without requesting broad storage access. On Android 9 and older, it requests the legacy storage permission and writes to the same public folder. Restore loads the newest JSON backup and validates its schema before replacing local records.

The backup feature protects data from uninstall and app-data clearing as long as the public backup file remains on the device. Android itself cannot guarantee preservation if a user manually deletes the backup or performs a full device wipe.

## GitHub Actions

The included workflow installs Flutter, runs analysis/tests, and builds split APKs. No credentials or tokens are required by this project.
