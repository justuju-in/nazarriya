# NazarRiya Flutter App  - Developer Setup

## Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Drift Database Code (Optional - for future database implementation)
```bash
flutter packages pub run build_runner build
```

### 3. Run the App
```bash
flutter run
```

## Features Added

### User Profile Screen
- **First Name**: Text input field (optional)
- **Age**: Number input field with validation (optional, 1-120)
- **Preferred Language**: Dropdown with English and Hindi options (optional)
- **State**: Dropdown with all Indian states (optional)

### Profile Icon
- Added to the bottom center of the home screen
- Circular purple icon with person symbol
- Tappable to navigate to profile screen

## Current Implementation
- Uses SharedPreferences for temporary data storage
- Form validation for age field
- Loading states and error handling
- Consistent UI design matching the app theme

## Future Enhancements
- Replace SharedPreferences with Drift database
- Add profile picture upload
- Implement data export/import
- Add profile completion percentage indicator

## File Structure
```
lib/
├── screens/
│   ├── home_screen.dart (updated with profile icon)
│   ├── profile_screen.dart (new)
│   └── ...
├── utils/
│   ├── constants.dart (Indian states and languages)
│   ├── profile_service.dart (data persistence)
│   └── database.dart (Drift setup for future use)
└── main.dart (updated with profile route)
```

## Dependencies Added
- `shared_preferences`: For local data storage
- `drift`: For future database implementation
- `sqlite3_flutter_libs`: SQLite support
- `path_provider`: File path utilities
- `path`: Path manipulation utilities
- `build_runner`: Code generation
- `drift_dev`: Drift development tools
