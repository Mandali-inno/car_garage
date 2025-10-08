import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as f_auth;

class EmergencyServiceScreen extends StatefulWidget {
  const EmergencyServiceScreen({super.key});

  @override
  State<EmergencyServiceScreen> createState() => _EmergencyServiceScreenState();
}

class _EmergencyServiceScreenState extends State<EmergencyServiceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedService = 'breakdown';
  Position? _currentPosition;
  final f_auth.FirebaseAuth _auth = f_auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Emergency Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedService,
              items: ['breakdown', 'tire swap', 'battery jump']
                  .map((service) => DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedService = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Select Service',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_currentPosition != null)
              Text(
                  'Your Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _currentPosition != null ? _submitRequest : null,
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRequest() async {
    f_auth.User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final request = EmergencyServiceRequest(
        id: '', // Firestore will generate an ID
        userId: currentUser.uid,
        serviceName: _selectedService,
        location: GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        requestTime: DateTime.now(),
        status: 'pending',
      );

      await _firestoreService.createEmergencyRequest(request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency request submitted!')),
        );

        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You need to be logged in to make a request')),
        );
      }
    }
  }
}
