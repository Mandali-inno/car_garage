import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';

class EditGarageScreen extends StatefulWidget {
  final Garage garage;

  const EditGarageScreen({super.key, required this.garage});

  @override
  State<EditGarageScreen> createState() => _EditGarageScreenState();
}

class _EditGarageScreenState extends State<EditGarageScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  List<String> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.garage.name);
    _latitudeController = TextEditingController(text: widget.garage.location.latitude.toString());
    _longitudeController = TextEditingController(text: widget.garage.location.longitude.toString());
    _selectedServices = widget.garage.services;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Garage'),
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
                _buildServiceSelection(),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _updateGarage,
                  child: const Text('Update Garage'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return StreamBuilder<List<Service>>(
      stream: _firestoreService.getAllServices(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final services = snapshot.data!;
        return MultiSelectDialogField(
          items: services.map((e) => MultiSelectItem(e.id, e.name)).toList(),
          title: const Text("Services"),
          selectedColor: Colors.blue,
          initialValue: _selectedServices,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          buttonIcon: const Icon(
            Icons.arrow_downward,
            color: Colors.blue,
          ),
          buttonText: const Text(
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
      },
    );
  }

  void _updateGarage() async {
    if (_formKey.currentState!.validate()) {
      final updatedGarage = Garage(
        id: widget.garage.id,
        name: _nameController.text,
        location: GeoPoint(
          double.parse(_latitudeController.text),
          double.parse(_longitudeController.text),
        ),
        ownerId: widget.garage.ownerId,
        services: _selectedServices,
        rating: widget.garage.rating,
      );
      await _firestoreService.updateGarage(updatedGarage);
      context.go('/manage-garages');
    }
  }
}
