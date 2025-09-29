import 'package:flutter/material.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/garage-list');
              },
              child: const Text('View Garages'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/emergency-request');
              },
              child: const Text('Request Emergency Service'),
            ),
          ],
        ),
      ),
    );
  }
}
