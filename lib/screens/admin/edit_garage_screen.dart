import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.garage.name);
    _latitudeController = TextEditingController(text: widget.garage.location.latitude.toString());
    _longitudeController = TextEditingController(text: widget.garage.location.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Garage'),
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
      );
      await _firestoreService.updateGarage(updatedGarage);
      Navigator.pop(context);
    }
  }
}
