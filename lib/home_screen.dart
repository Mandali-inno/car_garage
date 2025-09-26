import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';
import 'services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = _location.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (mounted) {
        setState(() {
          _currentLocation = currentLocation;
        });
      }
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Service Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentLocation != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      _currentLocation!.latitude!,
                      _currentLocation!.longitude!,
                    ),
                    15,
                  ),
                );
              }
            },
            tooltip: 'My Location',
          ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
              tooltip: 'Profile',
            ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.add_business),
              onPressed: () => context.go('/register-garage'),
              tooltip: 'Register Garage',
            ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? ''),
              ),
            ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authService.signOut(),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Stack(children: [_buildMap(), _buildSlidingPanel()]),
    );
  }

  Widget _buildMap() {
    return StreamBuilder<QuerySnapshot>(
      stream: _selectedService == null
          ? FirebaseFirestore.instance.collection('garages').snapshots()
          : FirebaseFirestore.instance
                .collectionGroup('services')
                .where('name', isEqualTo: _selectedService)
                .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading map'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final garages = snapshot.data!.docs;
        final Set<Marker> markers = garages.map((garage) {
          final data = garage.data() as Map<String, dynamic>;
          final location = data['location'] as GeoPoint;
          return Marker(
            markerId: MarkerId(garage.id),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: data['name'],
              snippet: data['address'],
            ),
            onTap: () {
              context.go('/garage/${garage.id}');
            },
          );
        }).toSet();

        if (_currentLocation != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('userLocation'),
              position: LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
        }

        return GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(37.7749, -122.4194), // Default to San Francisco
            zoom: 12,
          ),
          markers: markers,
          myLocationEnabled: true,
        );
      },
    );
  }

  Widget _buildSlidingPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Services',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('services')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    final services = snapshot.data!.docs;
                    return DropdownButton<String>(
                      value: _selectedService,
                      hint: const Text('Filter by Service'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Services'),
                        ),
                        ...services.map((service) {
                          return DropdownMenuItem<String>(
                            value: service.id,
                            child: Text(service['name']),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value;
                        });
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
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
                      controller: scrollController,
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return ListTile(
                          leading: const Icon(Icons.build),
                          title: Text(service['name']),
                          onTap: () {
                            setState(() {
                              _selectedService = service.id;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
