# Flutter Calculator

A minimal, offline Flutter calculator app for Android, built with Flutter.

## Features

- Addition, subtraction, multiplication, and division
- Decimal input, sign toggle, and percentage
- Repeated equals for the last operation
- Clear and divide by zero handling
- Pure-black interface with white controls and text
- No network access or third-party runtime packages

## Build

Run these commands from the repository root:

    flutter pub get
    flutter analyze
    flutter test
    flutter build apk --release

The release APK is created at:

    build/app/outputs/flutter-apk/app-release.apk

## Signed Android releases

Pushing a semantic-version tag such as `v1.0.0` starts the signed Android release workflow. The workflow installs dependencies, runs analysis and tests, builds the APK, verifies its signature with Android `apksigner`, and publishes a GitHub Release containing:

- `app-release.apk` — the signed Android APK
- `SHA256SUMS.txt` — the APK SHA-256 checksum

The workflow reads these GitHub Actions repository secrets:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`

The signing keystore is stored in GitHub Actions secrets, not in the repository. Local signing files (`android/key.properties` and `android/app/upload-keystore.jks`) are ignored by Git and must never be committed. The normal CI APK artifact is a build-validation artifact; only the tag-triggered release workflow publishes the APK signed with the dedicated upload key.

## Project

- Application ID: `com.hyouka.calculator`
- Flutter package: `flutter_calculator`
- License: MIT
