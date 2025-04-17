import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:kontak_application_2/responders/emergency_incident.dart';
import 'package:kontak_application_2/responders/incident_detail_page.dart';
import 'package:kontak_application_2/responders/responders_database.dart';
import 'package:kontak_application_2/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncidentsTab extends StatefulWidget {
  @override
  State<IncidentsTab> createState() => _IncidentsTabState();
}

class _IncidentsTabState extends State<IncidentsTab> {
  final RespondentDatabase _firestoreService = RespondentDatabase();

  Set<String> _displayedIncidentIds = {};

  @override
  void initState() {
    super.initState();
    _loadDisplayedIncidentIds();
  }

  Future<void> _loadDisplayedIncidentIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('displayedIncidentIds') ?? [];
    setState(() {
      _displayedIncidentIds = ids.toSet();
    });
  }

  Future<void> _saveDisplayedIncidentIds() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('displayedIncidentIds', _displayedIncidentIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('User not authenticated.'));
    }

    return FutureBuilder<String?>(
      future: _firestoreService
          .fetchUserStationID(user.uid), // Use user ID from Firebase Auth
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userStationID = snapshot.data;

        if (userStationID == null) {
          return Center(child: Text('User station ID not found.'));
        }

        return StreamBuilder<List<EmergencyIncident>>(
          stream: _firestoreService
              .getEmergencyIncidents(userStationID), // Pass the station ID
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final incidents = snapshot.data ?? [];
            final Set<String> newIncidentIds = {};

            // Check for new incidents
            for (var incident in incidents) {
              if (!_displayedIncidentIds.contains(incident.referenceNumber)) {
                newIncidentIds.add(incident.referenceNumber);

                // Trigger notification for this specific incident
                NotificationService.showNotification(
                  title: "New Incident: ${incident.name}",
                  body:
                      "Contact: ${incident.contactNumber} - Ref ID: ${incident.referenceNumber}",
                );
              }
            }

            // Update and persist displayed incident IDs
            if (newIncidentIds.isNotEmpty) {
              _displayedIncidentIds.addAll(newIncidentIds);
              _saveDisplayedIncidentIds(); // Persist the updates
            }

            if (incidents.isEmpty) {
              return Center(child: Text('No active incidents found.'));
            }

            return ListView.builder(
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];

                return Card(
                  color: Colors.green[200],
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        incident.profilePictureUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Text(
                                incident.name.isNotEmpty
                                    ? incident.name
                                    : 'No Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text('Reference ID: ${incident.referenceNumber}'),
                              Text(
                                  'Date & Time: ${DateFormat.yMMMd().add_jm().format(incident.dateTime)}'),
                              Text('Address: ${incident.address}'),
                              Text('Contact: ${incident.contactNumber}'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IncidentDetailsPage(
                                          incident: incident),
                                    ),
                                  );
                                },
                                child: Text('Accept',
                                    style: TextStyle(color: Colors.white)),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.lightGreen),
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context, incident);
                                },
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.white)),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, EmergencyIncident incident) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this incident?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _firestoreService
                    .deleteEmergencyIncident(incident.referenceNumber);
                Navigator.of(context).pop(); // Close the dialog
                // Optionally show a success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Incident deleted successfully.')),
                );
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
