import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';

class GarageListScreen extends StatefulWidget {
  const GarageListScreen({super.key});

  @override
  State<GarageListScreen> createState() => _GarageListScreenState();
}

class _GarageListScreenState extends State<GarageListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garages'),
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

          if (_currentPosition != null) {
            garages.sort((a, b) {
              double distanceA = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                a.location.latitude,
                a.location.longitude,
              );
              double distanceB = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                b.location.latitude,
                b.location.longitude,
              );
              return distanceA.compareTo(distanceB);
            });
          }

          return ListView.builder(
            itemCount: garages.length,
            itemBuilder: (context, index) {
              Garage garage = garages[index];
              double distance = 0;
              if (_currentPosition != null) {
                distance = Geolocator.distanceBetween(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      garage.location.latitude,
                      garage.location.longitude,
                    ) / 1000; // to kilometers
              }

              return ListTile(
                title: Text(garage.name),
                subtitle: Text('Distance: ${distance.toStringAsFixed(2)} km'),
                onTap: () {
                  context.go('/garage-details', extra: garage);
                },
              );
            },
          );
        },
      ),
    );
  }
}
