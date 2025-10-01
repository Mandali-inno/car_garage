import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;
import '../../models.dart';
import '../../services/firestore_service.dart';

class BookServiceScreen extends StatefulWidget {
  final Garage garage;

  const BookServiceScreen({super.key, required this.garage});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final fAuth.FirebaseAuth _auth = fAuth.FirebaseAuth.instance;
  String? _selectedService;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Service:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Service>>(
              stream: _firestoreService.getServicesForGarage(widget.garage.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No services available for this garage.');
                }

                final services = snapshot.data!;

                return DropdownButtonFormField<String>(
                  value: _selectedService,
                  hint: const Text('Select a service'),
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value;
                    });
                  },
                  items: services.map((service) {
                    return DropdownMenuItem<String>(
                      value: service.id,
                      child: Text(service.name),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Select a Date and Time:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDate),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
              child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bookService,
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _bookService() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book a service.')),
      );
      return;
    }

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service.')),
      );
      return;
    }

    final service = await _firestoreService.getService(_selectedService!);

    final booking = Booking(
      id: '',
      userId: user.uid,
      garageId: widget.garage.id,
      service: service.toFirestore(),
      bookingTime: _selectedDate,
      status: 'pending',
    );

    await _firestoreService.createBooking(booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking successful!')),
    );
    context.pop();
  }
}
