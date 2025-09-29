import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarageRegistrationScreen extends StatefulWidget {
  const GarageRegistrationScreen({super.key});

  @override
  State<GarageRegistrationScreen> createState() =>
      _GarageRegistrationScreenState();
}

class _GarageRegistrationScreenState extends State<GarageRegistrationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  LatLng? _garageLocation;

  Future<void> _registerGarage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to register a garage.'),
        ),
      );
      return;
    }

    try {
      final garageRef = await FirebaseFirestore.instance
          .collection('garages')
          .add({
            'ownerId': user.uid,
            'name': _nameController.text,
            'address': _addressController.text,
            'phone': _phoneController.text,
            'location': GeoPoint(
              _garageLocation!.latitude,
              _garageLocation!.longitude,
            ),
          });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'role': 'garage_owner',
        'garageId': garageRef.id,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garage registered successfully!')),
      );

      context.go('/garage-management');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering garage: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Your Garage')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _currentStep++;
              });
            }
          } else if (_currentStep == 1) {
            if (_garageLocation != null) {
              setState(() {
                _currentStep++;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a location on the map.'),
                ),
              );
            }
          } else if (_currentStep == 2) {
            _registerGarage();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Basic Information'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Garage Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your garage name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Location'),
            content: SizedBox(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    37.7749,
                    -122.4194,
                  ), // Default to San Francisco
                  zoom: 12,
                ),
                onTap: (location) {
                  setState(() {
                    _garageLocation = location;
                  });
                },
                markers: {
                  if (_garageLocation != null)
                    Marker(
                      markerId: const MarkerId('garageLocation'),
                      position: _garageLocation!,
                    ),
                },
              ),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Confirmation'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${_nameController.text}'),
                Text('Address: ${_addressController.text}'),
                Text('Phone: ${_phoneController.text}'),
                if (_garageLocation != null)
                  Text(
                    'Location: ${_garageLocation!.latitude}, ${_garageLocation!.longitude}',
                  ),
              ],
            ),
            isActive: _currentStep >= 2,
            state: _currentStep == 2 ? StepState.editing : StepState.indexed,
          ),
        ],
      ),
    );
  }
}
