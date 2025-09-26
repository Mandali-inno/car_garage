import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GarageDetailsScreen extends StatefulWidget {
  final String garageId;

  const GarageDetailsScreen({super.key, required this.garageId});

  @override
  State<GarageDetailsScreen> createState() => _GarageDetailsScreenState();
}

class _GarageDetailsScreenState extends State<GarageDetailsScreen> {
  double _rating = 0;
  final _reviewController = TextEditingController();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _bookService(BuildContext context, DocumentSnapshot service) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book a service.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': user.uid,
      'garageId': widget.garageId,
      'serviceName': service['name'],
      'servicePrice': service['price'],
      'timestamp': FieldValue.serverTimestamp(),
      'userName': user.displayName ?? user.email,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service booked successfully!')),
    );
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to submit a review.')),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('reviews').add({
      'garageId': widget.garageId,
      'userId': user.uid,
      'userName': user.displayName,
      'rating': _rating,
      'review': _reviewController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _reviewController.clear();
    setState(() {
      _rating = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('garages').doc(widget.garageId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Garage not found'));
          }

          final garage = snapshot.data!.data() as Map<String, dynamic>;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(garage['name']),
                  background: garage['imageUrl'] != null
                      ? Image.network(
                          garage['imageUrl'],
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 100, color: Colors.grey),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(garage['address'], style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          _makePhoneCall(garage['phone']);
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Garage'),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Services', style: Theme.of(context).textTheme.titleLarge),
                      _buildServicesList(),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildReviewForm(),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
                      _buildReviews(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServicesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('garages')
          .doc(widget.garageId)
          .collection('services')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final services = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ListTile(
              title: Text(service['name']),
              subtitle: Text('₹${service['price']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  _bookService(context, service);
                },
                child: const Text('Book'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leave a Review', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Write your review here',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _submitReview,
          child: const Text('Submit Review'),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('garageId', isEqualTo: widget.garageId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data!.docs;

        if (reviews.isEmpty) {
          return const Center(child: Text('No reviews yet.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(review['userName']?[0] ?? ''),
                ),
                title: Text(review['userName'] ?? ''),
                subtitle: Text(review['review']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(review['rating'].toString()),
                    const Icon(Icons.star, color: Colors.amber),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
