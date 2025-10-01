
# Blueprint: Car Service Finder

This document outlines the project structure, features, and implementation plan for the Car Service Finder application.

## 1. Overview

The Car Service Finder is a Flutter application that connects car owners with service garages. Users can find nearby garages, view their services and ratings, book appointments, and request emergency assistance. Admins can manage garage information and view service requests.

## 2. Data Models

*   **User:**
    *   `uid`: String
    *   `email`: String
    *   `role`: String ('user' or 'admin')
*   **Garage:**
    *   `id`: String
    *   `name`: String
    *   `address`: String
    *   `location`: GeoPoint
    *   `services`: List<Service>
    *   `rating`: double
*   **Service:**
    *   `id`: String
    *   `name`: String
    *   `description`: String
    *   `category`: String ('Normal' or 'Emergency')
*   **Booking:**
    *   `id`: String
    *   `userId`: String
    *   `garageId`: String
    *   `service`: Service
    *   `bookingDate`: Timestamp
    *   `status`: String ('Pending', 'Confirmed', 'Completed', 'Cancelled')
*   **Rating:**
    *   `id`: String
    *   `userId`: String
    *   `garageId`: String
    *   `rating`: double
    *   `comment`: String
*   **EmergencyServiceRequest:**
    *   `id`: String
    *   `userId`: String
    *   `location`: GeoPoint
    *   `description`: String
    *   `status`: String ('Pending', 'In Progress', 'Completed')

## 3. Features

### User Features

*   **Dashboard:** Displays a welcome message and provides access to the app's main features.
*   **Garage List:** Shows a list of nearby garages, with options to filter by services and sort by rating.
*   **Garage Details:** Provides detailed information about a selected garage, including its services and ratings.
*   **Book Service:** Allows users to book a service from a selected garage.
*   **My Bookings:** Displays a list of all the user's past and upcoming bookings.
*   **Emergency Service:** Enables users to request emergency assistance by sending their current location and a description of the emergency to the admins.

### Admin Features

*   **Dashboard:** Provides an overview of the system and access to the admin features.
*   **Manage Garages:** Allows admins to add, edit, and delete garages, including their services.
*   **Emergency Requests:** Displays a list of pending emergency service requests, with the ability to view the user's location on a map.

## 4. Implementation Plan

1.  **Update Data Models:**
    *   Modify the `Garage` model in `lib/models.dart` to include a list of `Service` objects and a `rating` field.
    *   Create a `Service` model in `lib/models.dart`.
    *   Modify the `Booking` model in `lib/models.dart` to include a `service` field.
2.  **Enhance Service Management:**
    *   Update `lib/screens/admin/add_garage_screen.dart` and `lib/screens/admin/edit_garage_screen.dart` to allow admins to manage services for a garage.
3.  **Enable Service Booking:**
    *   Create `lib/screens/user/book_service_screen.dart`.
    *   Add a `createBooking` function to `lib/services/firestore_service.dart`.
4.  **Refine UI and Filtering:**
    *   Update `lib/screens/user/garage_details_screen.dart` to display services and ratings.
    *   Add filtering and sorting options to `lib/screens/user/garage_list_screen.dart`.

## 5. Chat History

User: Can you save the history of this chat?

Gemini: Of course. I will save the history of our conversation to the `blueprint.md` file as requested in your initial instructions. I will add a new section called "Chat History" and append our conversation there.

First, I need to read the current `blueprint.md` file.
