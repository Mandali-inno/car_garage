import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GarageManagementScreen extends StatefulWidget {
  const GarageManagementScreen({super.key});

  @override
  State<GarageManagementScreen> createState() => _GarageManagementScreenState();
}

class _GarageManagementScreenState extends State<GarageManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('You must be logged in to manage a garage.')),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Garage Management'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Bookings'),
              Tab(icon: Icon(Icons.build), text: 'Services'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingsView(user: user),
            _ServicesView(user: user),
            _ProfileView(user: user),
          ],
        ),
      ),
    );
  }
}

class _BookingsView extends StatelessWidget {
  final User user;

  const _BookingsView({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('garageId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!.docs;

        if (bookings.isEmpty) {
          return const Center(child: Text('You have no bookings yet.'));
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return ListTile(
              title: Text(booking['serviceName']),
              subtitle: Text('Booked by: ${booking['userName']}'),
            );
          },
        );
      },
    );
  }
}

class _ServicesView extends StatefulWidget {
  final User user;

  const _ServicesView({required this.user});

  @override
  State<_ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<_ServicesView> {
  Future<void> _showAddServiceDialog(DocumentReference garageRef) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a New Service'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a service name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await garageRef.collection('services').add({
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditServiceDialog(DocumentSnapshot service) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: service['name']);
    final priceController = TextEditingController(
      text: service['price'].toString(),
    );

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Service'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a service name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await service.reference.update({
                    'name': nameController.text,
                    'price': double.parse(priceController.text),
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteService(DocumentSnapshot service) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Service'),
          content: const Text('Are you sure you want to delete this service?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await service.reference.delete();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final garageRef = FirebaseFirestore.instance
        .collection('garages')
        .doc(widget.user.uid);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: garageRef.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs;

          if (services.isEmpty) {
            return const Center(child: Text('You have no services yet.'));
          }

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service['name']),
                subtitle: Text('₹${service['price']}'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditServiceDialog(service);
                    } else if (value == 'delete') {
                      _deleteService(service);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(garageRef),
        tooltip: 'Add Service',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final User user;

  const _ProfileView({required this.user});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _showEditGarageDialog(DocumentSnapshot garage) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: garage['name']);
    final addressController = TextEditingController(text: garage['address']);
    final phoneController = TextEditingController(text: garage['phone']);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Garage Information'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Garage Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await garage.reference.update({
                    'name': nameController.text,
                    'address': addressController.text,
                    'phone': phoneController.text,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImage(String garageId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final File imageFile = File(image.path);

    try {
      final Reference storageRef = FirebaseStorage.instance.ref().child(
        'garages/$garageId/profile.jpg',
      );
      await storageRef.putFile(imageFile);
      final String downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('garages')
          .doc(garageId)
          .update({'imageUrl': downloadUrl});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final garageRef = FirebaseFirestore.instance
        .collection('garages')
        .doc(widget.user.uid);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: garageRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Garage not found.'));
            }

            final garage = snapshot.data!;

            return Column(
              children: [
                if (garage['imageUrl'] != null)
                  Image.network(
                    garage['imageUrl'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _uploadImage(widget.user.uid),
                  child: const Text('Upload Garage Image'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text(garage['name']),
                ),
                ListTile(
                  title: const Text('Address'),
                  subtitle: Text(garage['address']),
                ),
                ListTile(
                  title: const Text('Phone'),
                  subtitle: Text(garage['phone']),
                ),
                ElevatedButton(
                  onPressed: () => _showEditGarageDialog(garage),
                  child: const Text('Edit Information'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
