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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Services', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      StreamBuilder<List<Service>>(
                        stream: _firestoreService.getServicesForGarage(garage.id),
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

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              Service service = services[index];
                              return ListTile(
                                leading: const Icon(Icons.miscellaneous_services),
                                title: Text(service.name),
                                subtitle: Text('Category: ${service.category}'),
                                trailing: Text('₹${service.price}'),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/book-service', extra: garage);
                        },
                        child: const Text('Book a Service'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ratings', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
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

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: ratings.length,
                            itemBuilder: (context, index) {
                              Rating rating = ratings[index];
                              return ListTile(
                                leading: const Icon(Icons.star),
                                title: Text('Rating: ${rating.rating}'),
                                subtitle: Text(rating.review),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
