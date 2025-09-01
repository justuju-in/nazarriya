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

## Building APK Files for Distribution

### Prerequisites for APK Generation
- Ensure you have completed the setup steps above
- Make sure your code is working and tested

### Steps to Generate APK Files

#### 1. Update Version (Important!)
**Always increment the build number** in `pubspec.yaml` before building:
```yaml
version: 1.0.0+2  # Increment the +2 part for each new build
```

#### 2. Clean and Get Dependencies
```bash
flutter clean && flutter pub get
```

#### 3. Generate Split APKs (Recommended for Firebase App Distribution)
```bash
flutter build apk --split-per-abi --release
```

This generates three optimized APK files:
- `app-arm64-v8a-release.apk` - For ARM64 devices (most modern phones)
- `app-armeabi-v7a-release.apk` - For ARM32 devices (older phones)
- `app-x86_64-release.apk` - For x86_64 devices (emulators, some tablets)

#### 4. Alternative: Generate Single APK
```bash
flutter build apk --release
```

#### 5. Locate Generated Files
APK files are generated in: `build/app/outputs/flutter-apk/`

### Version Information
- **Version name** (X.Y.Z): What users see in the app
- **Build number** (+B): Internal version code for app stores
- Example: `version: 1.0.0+2` = Version 1.0.0, Build 2

### Distribution
- Upload split APKs to Firebase App Distribution for automatic device-specific distribution
- Users will automatically receive the correct APK for their device architecture
