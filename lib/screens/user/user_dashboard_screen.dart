import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                context.go('/garage-list');
              },
              child: const Text('View Garages'),
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/emergency-request');
              },
              child: const Text('Request Emergency Service'),
            ),
          ],
        ),
      ),
    );
  }
}
