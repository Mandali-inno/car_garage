import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User operations
  Future<void> addUser(User user) {
    return _db.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<User?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  }

  // Garage operations
  Future<void> addGarage(Garage garage) {
    return _db.collection('garages').add(garage.toFirestore());
  }

  Stream<List<Garage>> getGarages() {
    return _db.collection('garages').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Garage.fromFirestore(doc)).toList());
  }

  Future<void> updateGarage(Garage garage) {
    return _db.collection('garages').doc(garage.id).update(garage.toFirestore());
  }

  Future<void> deleteGarage(String garageId) {
    return _db.collection('garages').doc(garageId).delete();
  }

  // Service operations
  Future<void> addService(Service service) {
    return _db.collection('services').add(service.toFirestore());
  }

  Stream<List<Service>> getServicesForGarage(String garageId) {
    return _db.collection('garages').doc(garageId).snapshots().asyncMap((garageDoc) async {
      if (!garageDoc.exists) {
        return <Service>[];
      }
      List<dynamic> serviceIds = garageDoc.data()!['services'] ?? [];
      if (serviceIds.isEmpty) {
        return <Service>[];
      }

      final servicesSnapshot = await _db.collection('services').where(FieldPath.documentId, whereIn: serviceIds).get();
      return servicesSnapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Service>> getAllServices() {
    return _db.collection('services').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList());
  }

  Future<Service> getService(String serviceId) async {
    DocumentSnapshot doc = await _db.collection('services').doc(serviceId).get();
    return Service.fromFirestore(doc);
  }

  Future<void> updateService(Service service) {
    return _db.collection('services').doc(service.id).update(service.toFirestore());
  }

  Future<void> deleteService(String serviceId) {
    return _db.collection('services').doc(serviceId).delete();
  }

  // Booking operations
  Future<void> createBooking(Booking booking) {
    return _db.collection('bookings').add(booking.toFirestore());
  }

  Stream<List<Booking>> getUserBookings(String userId) {
    return _db.collection('bookings').where('userId', isEqualTo: userId).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  // Rating operations
  Future<void> addRating(Rating rating) {
    return _db.collection('ratings').add(rating.toFirestore());
  }

  Stream<List<Rating>> getGarageRatings(String garageId) {
    return _db.collection('ratings').where('garageId', isEqualTo: garageId).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Rating.fromFirestore(doc)).toList());
  }

  // Emergency Service Request operations
  Future<void> createEmergencyRequest(EmergencyServiceRequest request) {
    return _db.collection('emergencyRequests').add(request.toFirestore());
  }

  Stream<List<EmergencyServiceRequest>> getEmergencyRequests() {
    return _db
        .collection('emergencyRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyServiceRequest.fromFirestore(doc))
            .toList());
  }
}
