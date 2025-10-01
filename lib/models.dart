import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String role; // 'user' or 'admin'

  User({required this.uid, required this.email, required this.role});

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
    };
  }
}

class Garage {
  final String id;
  final String name;
  final GeoPoint location;
  final String ownerId;
  final List<String> services;
  final double rating;

  Garage({required this.id, required this.name, required this.location, required this.ownerId, required this.services, required this.rating});

  factory Garage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Garage(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? GeoPoint(0,0),
      ownerId: data['ownerId'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }

   Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'ownerId': ownerId,
      'services': services,
      'rating': rating,
    };
  }
}

class Service {
  final String id;
  final String name;
  final double price;
  final String category; // 'Normal' or 'Emergency'

  Service({required this.id, required this.name, required this.price, required this.category});

   factory Service.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? 'Normal',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }
}

class Booking {
  final String id;
  final String userId;
  final String garageId;
  final Map<String, dynamic> service;
  final DateTime bookingTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'

  Booking({required this.id, required this.userId, required this.garageId, required this.service, required this.bookingTime, required this.status});

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      garageId: data['garageId'] ?? '',
      service: data['service'] ?? {},
      bookingTime: (data['bookingTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'garageId': garageId,
      'service': service,
      'bookingTime': bookingTime,
      'status': status,
    };
  }
}

class Rating {
  final String id;
  final String userId;
  final String garageId;
  final double rating;
  final String review;

  Rating({required this.id, required this.userId, required this.garageId, required this.rating, required this.review});

  factory Rating.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Rating(
      id: doc.id,
      userId: data['userId'] ?? '',
      garageId: data['garageId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      review: data['review'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'garageId': garageId,
      'rating': rating,
      'review': review,
    };
  }
}

class EmergencyServiceRequest {
  final String id;
  final String userId;
  final String serviceName; // 'breakdown', 'tire swap', 'battery jump'
  final GeoPoint location;
  final DateTime requestTime;
  final String status; // 'pending', 'accepted', 'completed'
  final String? assignedGarageId;

  EmergencyServiceRequest({
    required this.id,
    required this.userId,
    required this.serviceName,
    required this.location,
    required this.requestTime,
    required this.status,
    this.assignedGarageId,
  });

  factory EmergencyServiceRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EmergencyServiceRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      location: data['location'] ?? GeoPoint(0,0),
      requestTime: (data['requestTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      assignedGarageId: data['assignedGarageId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'serviceName': serviceName,
      'location': location,
      'requestTime': requestTime,
      'status': status,
      'assignedGarageId': assignedGarageId,
    };
  }
}
