import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';

class GarageDetailsScreen extends StatelessWidget {
  final Garage garage;
  final FirestoreService _firestoreService = FirestoreService();

  GarageDetailsScreen({super.key, required this.garage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(garage.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Services', style: Theme.of(context).textTheme.headlineSmall),
            StreamBuilder<List<Service>>(
              stream: _firestoreService.getServices(garage.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No services available.');
                }

                List<Service> services = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      Service service = services[index];
                      return ListTile(
                        title: Text(service.name),
                        subtitle: Text('₹${service.price}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            context.go(
                              '/book-service',
                              extra: {'garage': garage, 'service': service},
                            );
                          },
                          child: const Text('Book Now'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text('Ratings', style: Theme.of(context).textTheme.headlineSmall),
            StreamBuilder<List<Rating>>(
              stream: _firestoreService.getGarageRatings(garage.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No ratings yet.');
                }

                List<Rating> ratings = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      Rating rating = ratings[index];
                      return ListTile(
                        title: Text('Rating: ${rating.rating}'),
                        subtitle: Text(rating.review),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
