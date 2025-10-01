import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;

class AddGarageScreen extends StatefulWidget {
  const AddGarageScreen({super.key});

  @override
  State<AddGarageScreen> createState() => _AddGarageScreenState();
}

class _AddGarageScreenState extends State<AddGarageScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final fAuth.FirebaseAuth _auth = fAuth.FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  List<String> _selectedServices = [];
  final _serviceNameController = TextEditingController();
  final _servicePriceController = TextEditingController();
  String _serviceCategory = 'Normal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Garage'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/manage-garages'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Garage Name',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    prefixIcon: Icon(Icons.pin_drop),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a latitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    prefixIcon: Icon(Icons.pin_drop),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a longitude';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildServiceManagement(),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _addGarage,
                  child: const Text('Add Garage'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _serviceNameController,
          decoration: const InputDecoration(
            labelText: 'Service Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _servicePriceController,
          decoration: const InputDecoration(
            labelText: 'Service Price',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _serviceCategory,
          decoration: const InputDecoration(
            labelText: 'Service Category',
            border: OutlineInputBorder(),
          ),
          items: ['Normal', 'Emergency'].map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) {
            setState(() {
              _serviceCategory = value!;
            });
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addService,
          child: const Text('Add Service'),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<Service>>(
            stream: _firestoreService.getAllServices(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final services = snapshot.data!;
              return MultiSelectDialogField(
                items: services.map((e) => MultiSelectItem(e.id, e.name)).toList(),
                title: Text("Services"),
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                buttonIcon: Icon(
                  Icons.arrow_downward,
                  color: Colors.blue,
                ),
                buttonText: Text(
                  "Select Services",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  _selectedServices = results.cast<String>();
                },
              );
            }),
      ],
    );
  }

  void _addService() async {
    if (_serviceNameController.text.isNotEmpty &&
        _servicePriceController.text.isNotEmpty) {
      final service = Service(
        id: '',
        name: _serviceNameController.text,
        price: double.parse(_servicePriceController.text),
        category: _serviceCategory,
      );
      await _firestoreService.addService(service);
      _serviceNameController.clear();
      _servicePriceController.clear();
    }
  }

  void _addGarage() async {
    if (_formKey.currentState!.validate()) {
      fAuth.User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final garage = Garage(
          id: '', // Firestore will generate ID
          name: _nameController.text,
          location: GeoPoint(
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
          ),
          ownerId: currentUser.uid,
          services: _selectedServices,
          rating: 0,
        );
        await _firestoreService.addGarage(garage);
        context.go('/manage-garages');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to add a garage')),
        );
      }
    }
  }
}
