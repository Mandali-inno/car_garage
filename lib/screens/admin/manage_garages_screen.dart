import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';

class ManageGaragesScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ManageGaragesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<List<Garage>>(
        stream: _firestoreService.getGarages(),
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

          List<Garage> garages = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: garages.length,
            itemBuilder: (context, index) {
              Garage garage = garages[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.store, size: 40),
                  title: Text(garage.name, style: Theme.of(context).textTheme.titleLarge),
                  subtitle: Text('Lat: ${garage.location.latitude}, Long: ${garage.location.longitude}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.go('/edit-garage', extra: garage);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _firestoreService.deleteGarage(garage.id);
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
}
