# app

NazarRiya mobile app

## Current Support
Android (iOS coming up)

## Installation
Coming up!


# Developer Setup

## Prerequisites
- Flutter SDK (3.9.0 or higher) - https://docs.flutter.dev/get-started/install
- Android Studio / VS Code with Flutter extensions - https://developer.android.com/studio

## Setup Instructions

### 0. Check Flutter installation
```bash
flutter doctor -v
```
Ensure that all items show with a green tick.

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Server Connection
The app can connect to different server environments.

**Quick Setup:**
- For local development: No changes needed (default)
- For remote server: Edit `lib/utils/config.dart` and set `_currentEnvironment = Environment.remote`
- For Android emulator testing: Set `_currentEnvironment = Environment.androidEmulator`

### 3. Start an Android emulator device
1. Go to Android Studio
2. Virtual Device Manager (you might have to click the 3 vertical dots to the right)
3. Hit Run on any Android device of your choice. E.g. Pixel 9 Pro

### 4. Run the App
```bash
flutter run
```
