import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;
import '../../models.dart';
import '../../services/firestore_service.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final fAuth.FirebaseAuth _auth = fAuth.FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to see your bookings.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: _firestoreService.getUserBookings(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have no bookings.'));
          }

          List<Booking> bookings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              Booking booking = bookings[index];

              // Note: You might want to fetch garage and service details here to display their names
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.event, size: 40),
                  title: Text('Booking ID: ${booking.id}', style: Theme.of(context).textTheme.titleLarge),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${booking.bookingTime.toLocal()}'.split(' ')[0]),
                      Text('Status: ${booking.status}'),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
