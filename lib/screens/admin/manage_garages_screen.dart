import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models.dart' as models;
import '../../services/firestore_service.dart';

class ManageGaragesScreen extends StatelessWidget {
  const ManageGaragesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Garages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go('/add-garage');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<models.Garage>>(
        stream: firestoreService.getGarages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No garages found.'));
          }

          List<models.Garage> garages = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: garages.length,
            itemBuilder: (context, index) {
              models.Garage garage = garages[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.store, size: 40),
                  title: Text(garage.name, style: Theme.of(context).textTheme.titleLarge),
                  subtitle: Text(
                      'Lat: ${garage.location.latitude}, Long: ${garage.location.longitude}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.blue),
                        onPressed: () => _showAssignOwnerDialog(context, garage, firestoreService),
                        tooltip: 'Assign Owner',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.go('/edit-garage', extra: garage);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          firestoreService.deleteGarage(garage.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAssignOwnerDialog(
      BuildContext context, models.Garage garage, FirestoreService firestoreService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<models.User>>(
          future: firestoreService.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load users: ${snapshot.error}'),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AlertDialog(
                title: const Text('No Users Found'),
                content: const Text('There are no users to assign as owner.'),
                actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
              );
            }

            final users = snapshot.data!;

            return AlertDialog(
              title: Text('Assign Owner for ${garage.name}'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.email),
                      onTap: () async {
                        try {
                          // Update garage with new owner
                          final updatedGarage = models.Garage(
                            id: garage.id,
                            name: garage.name,
                            location: garage.location,
                            garageOwnerId: user.uid,
                            services: garage.services,
                            rating: garage.rating,
                          );
                          await firestoreService.updateGarage(updatedGarage);

                          // Update user's role
                          await firestoreService.updateUserRole(user.uid, 'garageOwner');

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Assigned ${user.email} as owner of ${garage.name}')),
                          );
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error assigning owner: $e')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
