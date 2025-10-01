import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
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
  String _sortOption = 'distance';
  List<String> _selectedServiceFilters = [];
  List<Service> _allServices = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadServices();
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

  Future<void> _loadServices() async {
    final services = await _firestoreService.getServicesForGarage(' ').first;
    setState(() {
      _allServices = services;
    });
  }

  void _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: _allServices
              .map((service) => MultiSelectItem(service.id, service.name))
              .toList(),
          initialValue: _selectedServiceFilters,
          onConfirm: (values) {
            setState(() {
              _selectedServiceFilters = values.cast<String>();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Garages'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sortOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sortOption = newValue!;
                    });
                  },
                  items: <String>['distance', 'rating']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'distance'
                          ? 'Sort by Distance'
                          : 'Sort by Rating'),
                    );
                  }).toList(),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.filter_list),
                  label: Text('Filter'),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Garage>>(
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

                // Filtering
                if (_selectedServiceFilters.isNotEmpty) {
                  garages = garages.where((garage) {
                    return _selectedServiceFilters
                        .every((filter) => garage.services.contains(filter));
                  }).toList();
                }

                // Sorting
                if (_sortOption == 'distance' && _currentPosition != null) {
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
                } else if (_sortOption == 'rating') {
                  garages.sort((a, b) => b.rating.compareTo(a.rating));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
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
                          ) /
                          1000; // to kilometers
                    }

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.store, size: 40),
                        title: Text(garage.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        subtitle: Text(
                            '${distance.toStringAsFixed(2)} km away - Rating: ${garage.rating.toStringAsFixed(1)}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.go('/garage-details', extra: garage);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
