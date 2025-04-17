import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyIncident {
  final String referenceNumber;
  final String name;
  final String profilePictureUrl;
  final DateTime dateTime;
  final String address;
  final String contactNumber;
  final String status;
  final String? description;
  final String stationID;

  EmergencyIncident({
    required this.referenceNumber,
    required this.name,
    required this.profilePictureUrl,
    required this.dateTime,
    required this.address,
    required this.contactNumber,
    required this.status,
    this.description,
    required this.stationID,
  });

  factory EmergencyIncident.fromFirestore(Map<String, dynamic> data) {
    return EmergencyIncident(
      referenceNumber: data['reference_number'],
      name: data['user_name'],
      profilePictureUrl:
          data['profile_picture_url'], // Ensure this field exists
      dateTime: (data['date_time'] as Timestamp).toDate(),
      address: data['user_address'],
      contactNumber: data['user_contact'],
      status: data['status'],
      description: data['description'],
      stationID: data['station_id'],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  // You can add a factory method to create a Location instance from a Map
  factory Location.fromMap(Map<String, dynamic> data) {
    return Location(
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }
}
