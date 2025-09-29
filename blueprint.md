# Car Garage App

This application allows users to find and manage car garages. 

## Features:

* User authentication with email/password, Google Sign-In, and Apple Sign-In.
* Garage registration and management.
* View garage details.
* User profile screen.

## Current Task: Add iOS Support and Apple Sign-In

### Plan:

1.  **Create iOS app in Firebase:** An iOS app has been created in the Firebase project with the bundle ID `com.example.myapp.ios`.
2.  **Add `sign_in_with_apple` dependency:** The `sign_in_with_apple` package has been added to `pubspec.yaml` to enable Apple Sign-In.
3.  **Update `auth_service.dart`:** The `AuthService` class has been updated to include a `signInWithApple` method.
4.  **Update `login_screen.dart`:** The `LoginScreen` now displays a "Sign in with Apple" button on iOS devices.
5.  **Create iOS project files:** The necessary iOS project files have been created to enable the app to run on iOS.
6.  **Add `GoogleService-Info.plist`:** The Firebase configuration file for iOS has been added to the project.