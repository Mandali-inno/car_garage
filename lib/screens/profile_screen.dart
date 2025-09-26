import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(user?.displayName ?? 'Your Profile'),
              background: user?.photoURL != null
                  ? Image.network(
                      user!.photoURL!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.email ?? '', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!['role'] != 'garage_owner') {
                        return const SizedBox.shrink();
                      }
                      return Center(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/garage-management'),
                          icon: const Icon(Icons.store),
                          label: const Text('Manage My Garage'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('My Bookings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(thickness: 2),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBookingsList(user),
        ],
      ),
    );
  }

  Widget _buildBookingsList(User? user) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const SliverToBoxAdapter(child: Center(child: Text('Something went wrong')));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
          }

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'You have no bookings yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final booking = bookings[index];
                final date = (booking['timestamp'] as Timestamp).toDate();
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: Text(
                      booking['serviceName'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('garages').doc(booking['garageId']).get(),
                      builder: (context, garageSnapshot) {
                        if (garageSnapshot.connectionState == ConnectionState.done && garageSnapshot.hasData) {
                          return Text('at ${garageSnapshot.data!['name']}');
                        } else {
                          return const Text('Loading garage...');
                        }
                      },
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${booking['servicePrice']}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text('${date.day}/${date.month}/${date.year}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                );
              },
              childCount: bookings.length,
            ),
          );
        },
      ),
    );
  }
}
