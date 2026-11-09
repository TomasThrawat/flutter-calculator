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

Pushing a semantic-version tag such as `v1.0.0` starts the signed Android release workflow. The workflow installs dependencies, runs analysis and tests, builds the APK