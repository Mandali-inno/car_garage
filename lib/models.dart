import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  final String name;
  final GeoPoint location;
  final List<String> services;

  Garage({required this.name, required this.location, required this.services});
}

class Service {
  final String name;
  final double price;

  Service({required this.name, required this.price});
}
