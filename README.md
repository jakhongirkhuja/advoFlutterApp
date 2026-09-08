# Vatandoshlar

Vatandoshlar is a Flutter application currently focused on a clean authentication shell. The active user flow is phone-number login with OTP verification. The project also keeps the core services required for the next development stage: localization, API access, FCM notifications, and authenticated location synchronization.

## Current scope

- Phone-number login through the backend API
- OTP verification
- Multi-language localization
- Provider-based state management
- Repository and API-client layers
- Firebase Cloud Messaging notifications
- FCM token registration and refresh handling
- Current-location sharing after authentication
- Foreground location synchronization

All copied feature screens were removed. The only active UI screens are:

```text
lib/presentation/features/auth/screens/login_screen.dart
lib/presentation/features/auth/screens/otp_screen.dart
```

## Project structure

```text
lib/
├── core/
│   ├── config/app_config.dart          # API and media URLs
│   ├── localization/                  # Locale provider and translations
│   ├── routes/app_router.dart          # Login and OTP routes
│   ├── services/
│   │   ├── location_sync_service.dart  # Foreground location sync
│   │   └── notification_service.dart   # FCM and local notifications
│   └── theme/app_theme.dart
├── data/
│   ├── api/api_client.dart
│   ├── models/auth/user_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       └── home_repository.dart        # Location endpoints
├── presentation/features/auth/
│   ├── screens/
│   └── viewmodels/auth_viewmodel.dart
└── main.dart
```

## Configuration

Backend URLs are centralized in:

```text
lib/core/config/app_config.dart
```

Change these values when switching environments:

```dart
static const String apiBaseUrl = '...';
static const String mediaBaseUrl = '...';
```

## Requirements

- Flutter 3.44.9 or newer stable
- Dart SDK compatible with the Flutter version
- Android SDK for Android builds
- Visual Studio 2022 with the **Desktop development with C++** workload for Windows builds
- Firebase project configuration for FCM

## Firebase setup

Android Firebase configuration is expected at:

```text
android/app/google-services.json
```

For iOS builds, add the Firebase-generated file:

```text
ios/Runner/GoogleService-Info.plist
```

Do not commit private production credentials or sensitive Firebase configuration to a public repository unless that is acceptable for the project.

## Location setup

The app requests location permission after successful authentication and synchronizes the current location through the authenticated API client while the app is active.

Android and iOS location permission descriptions are configured in the platform files. Location sync is foreground-only.

The backend must support these authenticated endpoints:

```text
POST auth/sign-in
POST auth/verify-otp
GET  users/me
POST users/device-token
PUT  users/location/share
POST users/location
```

## Install and run

```powershell
flutter pub get
flutter doctor
flutter devices
flutter run -d <device-id>
```

For Windows desktop:

```powershell
flutter run -d windows
```

For Android:

```powershell
flutter run -d <android-device-id>
```

## Validation

Run static analysis before committing:

```powershell
flutter analyze
```

The project currently reports lint/info suggestions from the analyzer but no Dart compilation errors.

## Development notes

- The application intentionally stays on the login shell after authentication until the next feature area is implemented.
- The OTP screen is retained because it is part of the login connection flow.
- Notification and location services are initialized at application startup, while foreground location tracking is enabled only for authenticated users.
