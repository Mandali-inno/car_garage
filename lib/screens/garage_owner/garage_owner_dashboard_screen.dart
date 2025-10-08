
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models.dart' as models;
import '../../services/firestore_service.dart';

class GarageOwnerDashboardScreen extends StatefulWidget {
  const GarageOwnerDashboardScreen({super.key});

  @override
  State<GarageOwnerDashboardScreen> createState() =>
      _GarageOwnerDashboardScreenState();
}

class _GarageOwnerDashboardScreenState
    extends State<GarageOwnerDashboardScreen> {
  models.Garage? _garage;
  List<models.Booking> _bookings = [];
  List<models.Rating> _ratings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGarageData();
    });
  }

  Future<void> _fetchGarageData() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final garage = await firestoreService.getGarageByOwner(user.uid);
        if (mounted) {
          if (garage != null) {
            final bookings = await firestoreService.getBookingsForGarage(garage.id);
            final ratings = await firestoreService.getRatingsForGarage(garage.id);
            setState(() {
              _garage = garage;
              _bookings = bookings;
              _ratings = ratings;
            });
          } else {
            setState(() {
              _error = 'You are not assigned to any garage.';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching garage data: \$e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_garage == null) {
      return const Scaffold(
        body: Center(
          child: Text('No garage found for the current owner.'),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_garage!.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bookings', icon: Icon(Icons.calendar_today)),
              Tab(text: 'Ratings', icon: Icon(Icons.star)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingsView(),
            _buildRatingsView(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsView() {
    if (_bookings.isEmpty) {
      return const Center(child: Text('No bookings found.'));
    }
    return ListView.builder(
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(booking.service['name'] ?? 'Unknown Service'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Time: \${DateFormat.yMd().add_jm().format(booking.bookingTime)}'),
                Text('Status: \${booking.status}'),
              ],
            ),
            trailing: _buildBookingActions(booking),
          ),
        );
      },
    );
  }

  Widget _buildBookingActions(models.Booking booking) {
    if (booking.status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _updateBookingStatus(booking.id, 'confirmed'),
            tooltip: 'Confirm',
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _updateBookingStatus(booking.id, 'cancelled'),
            tooltip: 'Cancel',
          ),
        ],
      );
    } else if (booking.status == 'confirmed') {
      return ElevatedButton(
        onPressed: () => _updateBookingStatus(booking.id, 'completed'),
        child: const Text('Complete'),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    try {
      await firestoreService.updateBookingStatus(bookingId, newStatus);
      _fetchGarageData(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking status: \$e')),
      );
    }
  }

  Widget _buildRatingsView() {
    if (_ratings.isEmpty) {
      return const Center(child: Text('No ratings found.'));
    }
    return ListView.builder(
      itemCount: _ratings.length,
      itemBuilder: (context, index) {
        final rating = _ratings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(rating.rating.toString()),
            ),
            title: Text(rating.review),
            subtitle: Text('User: \${rating.userId}'),
          ),
        );
      },
    );
  }
}
