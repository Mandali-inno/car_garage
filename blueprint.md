# Car Service Finder Blueprint

## Overview

This document outlines the architecture, design, and features of the Car Service Finder application.

## Project Structure

```
lib/
├── main.dart
├── models.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
└── screens/
    ├── admin/
    │   ├── add_garage_screen.dart
    │   ├── admin_dashboard_screen.dart
    │   ├── emergency_requests_screen.dart
    │   └── manage_garages_screen.dart
    ├── user/
    │   ├── book_service_screen.dart
    │   ├── emergency_service_screen.dart
    │   ├── garage_details_screen.dart
    │   ├── garage_list_screen.dart
    │   └── user_bookings_screen.dart
    │   └── user_dashboard_screen.dart
    ├── login_screen.dart
    └── registration_screen.dart
```

## Design

The application uses the Material Design 3 design system with a purple-based color scheme. The typography is based on the Oswald, Roboto, and Open Sans font families, provided by the `google_fonts` package.

The UI is designed to be modern, clean, and user-friendly, with a focus on intuitive navigation and clear information hierarchy. The main layout consists of a `Scaffold` with a `BottomNavigationBar` for user roles and a `Drawer` for admin roles, providing easy access to all the app's features.

## Features

### User Authentication

*   Users can register for a new account or log in with their existing credentials.
*   The app uses Firebase Authentication for secure user authentication.
*   Role-based access control is implemented to differentiate between regular users and administrators.

### User Features

*   **Dashboard:** Displays a welcome message and provides access to the app's main features.
*   **Garage List:** Shows a list of nearby garages, sorted by distance from the user's current location.
*   **Garage Details:** Provides detailed information about a selected garage, including its services and ratings.
*   **Book Service:** Allows users to book a service from a selected garage.
*   **My Bookings:** Displays a list of all the user's past and upcoming bookings.
*   **Emergency Service:** Enables users to request emergency assistance by sending their current location and a description of the emergency to the admins.

### Admin Features

*   **Dashboard:** Provides an overview of the system and access to the admin features.
*   **Manage Garages:** Allows admins to add, edit, and delete garages.
*   **Emergency Requests:** Displays a list of pending emergency service requests, with the ability to view the user's location on a map.
