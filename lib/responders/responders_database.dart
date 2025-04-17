import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'emergency_incident.dart';

class RespondentDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or update station name in Firestore
  Future<void> saveStation(String stationName) async {
    try {
      // Get the current user (make sure the user is logged in)
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      // Reference to the user's document in Firestore
      await FirebaseFirestore.instance
          .collection('users') // Collection where user data is stored
          .doc(user.uid) // Use the user's UID as the document ID
          .update({
        'userStationID': stationName, // Update the station ID
      });

      print("Station updated successfully");
    } catch (e) {
      print("Error saving station name: $e");
    }
  }

  // Method to fetch user station ID
  Future<String?> fetchUserStationID(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['userStationID']; // Adjust the key as needed
      }
    } catch (e) {
      print('Error fetching user station ID: $e');
    }
    return null; // Return null if user not found or error occurs
  }

  // Method to delete an emergency incident
  Future<void> deleteEmergencyIncident(String referenceNumber) async {
    try {
      await _db.collection('emergency_incident').doc(referenceNumber).delete();
    } catch (e) {
      // Handle any errors that occur during deletion
      throw Exception('Failed to delete incident: $e');
    }
  }

  // Fetch active emergency incidents
  Stream<List<EmergencyIncident>> getEmergencyIncidents(userStationID) {
    return _db
        .collection('emergency_incident')
        .orderBy('date_time', descending: true) // Order by date
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyIncident.fromFirestore(
              doc.data() as Map<String, dynamic>))
          .where((incident) =>
              incident.status == 'active' &&
              incident.stationID == userStationID) // Filter in-memory
          .toList();
    });
  }

  // Fetch reported emergency incidents with date range filter
  Stream<List<EmergencyIncident>> getReportedIncidents(
      String userStationID, DateTimeRange? dateRange) {
    Query query = _db
        .collection('emergency_incident')
        .orderBy('date_time', descending: true); // Order by date

    // Apply date range filter if selected
    if (dateRange != null) {
      query = query
          .where('date_time', isGreaterThanOrEqualTo: dateRange.start)
          .where('date_time', isLessThanOrEqualTo: dateRange.end);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyIncident.fromFirestore(
              doc.data() as Map<String, dynamic>))
          .where((incident) =>
              incident.status == 'reported' &&
              incident.stationID == userStationID)
          .toList();
    });
  }

  // Fetch user location based on reference number
  Future<Location?> getUserLocation(String referenceNumber) async {
    try {
      DocumentSnapshot document = await _db
          .collection(
              'emergency_incident') // Adjusted to the correct collection name
          .doc(referenceNumber)
          .get();

      if (document.exists) {
        // Assuming your document structure contains latitude and longitude fields
        double latitude = document['latitude'];
        double longitude = document['longitude'];
        return Location(latitude: latitude, longitude: longitude);
      }
    } catch (e) {
      print('Error fetching user location: $e');
    }
    return null;
  }

  // Save an incident report to the reports collection
  Future<void> saveIncidentReport(Map<String, dynamic> report) async {
    await _db.collection('incident_reports').add(report);
  }

  // Update the incident with a description
  Future<void> updateIncidentWithDescription(
      String referenceNumber, String description) async {
    await _db.collection('emergency_incident').doc(referenceNumber).update({
      'description': description,
      // Include any other fields you want to update
    });
  }

  // Mark the incident as reported
  Future<void> markIncidentAsReported(String referenceNumber) async {
    await _db.collection('emergency_incident').doc(referenceNumber).update({
      'status': 'reported', // Update the status to reported
    });
  }

  // Create a new incident and return the reference number
  Future<void> createIncidentAndFetchDateTime(
    String emergencyNumber,
    String userId,
    String userName,
    String userAddress,
    String userContact,
    String userProfilePic,
    String? description, // Add description parameter
    double latitude,
    double longitude,
    String stationID,
  ) async {
    DateTime now = DateTime.now();

    // Add the incident first to get the document ID
    DocumentReference docRef = await _db.collection('emergency_incident').add({
      'emergency_number': emergencyNumber,
      'user_id': userId,
      'user_name': userName,
      'user_address': userAddress,
      'user_contact': userContact,
      'date_time': now, // Store as DateTime
      'profile_picture_url': userProfilePic,
      'status': 'active', // Initialize status to active
      'description': description, // Store the description
      'latitude': latitude,
      'longitude': longitude,
      'station_id': stationID,
    });

    // Update the document with the reference number (document ID)
    await docRef.update({
      'reference_number': docRef.id,
    });
  }

  // Fetch the latest incident date and time
  Future<DateTime?> fetchLatestIncidentDateTime() async {
    QuerySnapshot snapshot = await _db
        .collection('emergency_incident')
        .orderBy('date_time', descending: true)
        .limit(1) // Get the latest one
        .get();

    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.first.data() as Map<String, dynamic>;
      DateTime dateTime =
          (doc['date_time'] as Timestamp).toDate(); // Convert to DateTime
      return dateTime; // Return the DateTime
    }
    return null; // No incidents found
  }
}
