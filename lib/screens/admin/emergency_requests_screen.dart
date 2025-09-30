import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';

class EmergencyRequestsScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  EmergencyRequestsScreen({super.key});

  void _openLocationInMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Requests'),
      ),
      body: StreamBuilder<List<EmergencyServiceRequest>>(
        stream: _firestoreService.getEmergencyRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending emergency requests.'));
          }

          List<EmergencyServiceRequest> requests = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              EmergencyServiceRequest request = requests[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red, size: 40),
                  title: Text('Request from ${request.userId}', style: Theme.of(context).textTheme.titleLarge),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.serviceName),
                      const SizedBox(height: 5),
                      Text('Time: ${request.requestTime.toLocal()}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () => _openLocationInMaps(request.location.latitude, request.location.longitude),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
