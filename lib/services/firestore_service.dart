import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addInitialData() async {
    final garages = [
      {
        'name': 'Pimp My Ride',
        'location': const GeoPoint(40.7128, -74.0060),
        'services': ['General', 'Washing'],
      },
      {
        'name': 'The Auto Shop',
        'location': const GeoPoint(34.0522, -118.2437),
        'services': ['Painting', 'Tuning'],
      },
    ];

    final services = [
      {'name': 'General', 'price': 100.0},
      {'name': 'Washing', 'price': 50.0},
      {'name': 'Painting', 'price': 200.0},
      {'name': 'Tuning', 'price': 150.0},
    ];

    for (final garage in garages) {
      await _db.collection('garages').add(garage);
    }

    for (final service in services) {
      await _db.collection('services').add(service);
    }
  }
}
