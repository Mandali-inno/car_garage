import 'package:flutter/material.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fAuth;

class BookServiceScreen extends StatefulWidget {
  final Garage garage;
  final Service service;

  const BookServiceScreen({super.key, required this.garage, required this.service});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final fAuth.FirebaseAuth _auth = fAuth.FirebaseAuth.instance;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.service.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select a date and time for your booking:'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bookService,
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _bookService() async {
    fAuth.User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final booking = Booking(
        id: '', // Firestore will generate an ID
        userId: currentUser.uid,
        garageId: widget.garage.id,
        serviceId: widget.service.id,
        bookingTime: _selectedDate,
        status: 'pending',
      );

      await _firestoreService.createBooking(booking);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully!')),
      );
      Navigator.pop(context);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to book a service')),
      );
    }
  }
}
