import 'package:flutter/material.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';
import 'add_garage_screen.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddGarageScreen()),
              );
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
            itemCount: garages.length,
            itemBuilder: (context, index) {
              Garage garage = garages[index];
              return ListTile(
                title: Text(garage.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Implement edit garage functionality
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
              );
            },
          );
        },
      ),
    );
  }
}
