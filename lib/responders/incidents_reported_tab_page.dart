import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kontak_application_2/responders/emergency_incident.dart';
import 'package:kontak_application_2/responders/incidents_reported_detail_page.dart';
import 'package:kontak_application_2/responders/responders_database.dart';
import 'package:kontak_application_2/services/notification_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class IncidentsReportsTab extends StatefulWidget {
  @override
  State<IncidentsReportsTab> createState() => _IncidentsReportsTabState();
}

class _IncidentsReportsTabState extends State<IncidentsReportsTab> {
  final RespondentDatabase _firestoreService = RespondentDatabase();

  DateTimeRange? selectedDateRange;
  bool _isStoragePermissionGranted = false;

  Future<QuerySnapshot> _getIncidentData() async {
    Query query = FirebaseFirestore.instance
        .collection('emergency_incident')
        .where('status', isEqualTo: 'reported');

    if (selectedDateRange != null) {
      query = query
          .orderBy('date_time') // Ensure the query is ordered by 'date_time'
          .where('date_time', isGreaterThanOrEqualTo: selectedDateRange!.start)
          .where('date_time', isLessThanOrEqualTo: selectedDateRange!.end);
    }

    return await query.get();
  }

  Future<void> _exportData() async {
    // Check permissions
    await _checkPermissions();
    if (_isStoragePermissionGranted) {
      if (selectedDateRange == null) {
        // If no date range is selected, show a message and return
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a date range first')),
        );
        return;
      }

      try {
        QuerySnapshot incidentSnapshot = await _getIncidentData();

        List<List<dynamic>> incidentData = [];
        for (var doc in incidentSnapshot.docs) {
          DateTime dateTime = (doc['date_time'] as Timestamp).toDate();
          if (dateTime.isAfter(selectedDateRange!.start) &&
              dateTime.isBefore(selectedDateRange!.end)) {
            String status = doc['status'];
            String formattedDateTime =
                '${dateTime.year}-${dateTime.month}-${dateTime.day},\n${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
            String name = doc['user_name'];
            String stationCalled = doc['station_id'];
            double latitude = doc['latitude'];
            double longitude = doc['longitude'];
            String incidentLocation = "$latitude,\n$longitude";
            String number = doc['user_contact'];
            incidentData.add([
              formattedDateTime,
              name,
              stationCalled,
              status,
              incidentLocation,
              number
            ]);
          }
        }

        final pdf = pw.Document();

        // Add Incident Data to PDF
        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 10),
                pw.Text('Reported Incident Data',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: [
                    'Date &\nTime',
                    'Name',
                    'Station Called',
                    'Status',
                    'Incident\nLocation',
                    'Number'
                  ],
                  data: incidentData,
                  headerStyle: pw.TextStyle(
                    fontSize: 11, // Set the font size for the table header
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(
                    fontSize: 10, // Set the font size for table cells
                  ),
                ),
              ],
            );
          },
        ));

        try {
          if (Platform.isAndroid) {
            // final directory = await getExternalStorageDirectory();
            final downloadsDirectory =
                Directory('/storage/emulated/0/Download');

            String filePath =
                '${downloadsDirectory.path}/reported_incident_data.pdf';
            File file = File(filePath);

            await NotificationService.showNotification(
                title: "Exporting Data", body: "Starting file export...");

            await file.writeAsBytes(await pdf.save());

            await NotificationService.showNotification(
                title: "Export Complete", body: "File exported to $filePath");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Only available for Android')),
            );
          }
        } catch (e) {
          await NotificationService.showNotification(
              title: "Export Failed", body: "Error during export: $e");
        }
      } catch (e) {
        print('Error during export: $e');
        await NotificationService.showNotification(
            title: "Export Failed", body: "Failed to export data: $e");
      }
    }
  }

  Future<void> _checkPermissions() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;

    if (status.isGranted) {
      // If the permission is granted
      setState(() {
        _isStoragePermissionGranted = true;
      });
    } else if (status.isDenied) {
      // If the permission is denied, request it
      PermissionStatus newStatus =
          await Permission.manageExternalStorage.request();

      setState(() {
        _isStoragePermissionGranted = newStatus.isGranted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Permission denied. Please allow access to your files.')),
      );
    } else if (status.isPermanentlyDenied) {
      // If the permission is permanently denied, guide the user to settings
      setState(() {
        _isStoragePermissionGranted = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable storage permission in the app files.'),
          action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () async {
                openAppSettings();
              }),
        ),
      );
    }
  }

  // Date picker for selecting the date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        final primaryColor = Color(0xFF18A54A); // Custom primary color
        final secondaryColor = Color(0xFF18A54A); // Custom secondary color

        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: primaryColor, // Primary color for the app
            hintColor: secondaryColor,
            scaffoldBackgroundColor: Color.fromRGBO(202, 230, 241, 1),
            colorScheme: ColorScheme.light(
              primary: primaryColor, // Primary color for the app
              secondary: secondaryColor, // Secondary accent color
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary, // Button text color
            ),
          ),
          child: child!,
        );
      },
    );

    // Check if a date range is picked and if it's a valid selection
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        // If the start and end date are the same, treat it as a single day.
        if (picked.start.isAtSameMomentAs(picked.end)) {
          selectedDateRange = DateTimeRange(
            start: picked.start,
            end: DateTime(picked.start.year, picked.start.month,
                picked.start.day, 23, 59, 59, 999),
          );
        } else {
          selectedDateRange = DateTimeRange(
            start: picked.start,
            end: DateTime(picked.end.year, picked.end.month, picked.end.day, 23,
                59, 59, 999),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('User not authenticated.'));
    }

    return Column(
      children: [
        // Date Selection UI
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                selectedDateRange == null
                    ? 'Date Filter:'
                    : 'Date Filter: ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              // Date range selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF18A54A),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: InkWell(
                        onTap: () => _selectDateRange(
                            context), // Tap to open date picker
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Date Range',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF18A54A),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: InkWell(
                        onTap: _exportData, // Call the export function
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // Space out title and icon
                            children: [
                              Text(
                                'Export Data',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16, // Adjust font size if needed
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.file_download,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        FutureBuilder<String?>(
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
              stream: _firestoreService.getReportedIncidents(
                  userStationID, selectedDateRange), // Updated method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final incidents = snapshot.data ?? [];

                if (incidents.isEmpty) {
                  return Center(child: Text('No past incidents found.'));
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: incidents.length,
                    itemBuilder: (context, index) {
                      final incident = incidents[index];

                      return Card(
                        color: Colors.blue[200],
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                        'Reference ID: ${incident.referenceNumber}'),
                                    Text(
                                      'Date & Time: ${DateFormat.yMMMd().add_jm().format(incident.dateTime)}',
                                    ),
                                    Text('Address: ${incident.address}'),
                                    Text('Contact: ${incident.contactNumber}'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReportedIncidentDetailsPage(
                                                    incident: incident),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3),
                                        child: Text(
                                          'View\nDetails',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blue),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(
                                            context, incident);
                                      },
                                      child: Text('Delete',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red),
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
                  ),
                );
              },
            );
          },
        ),
      ],
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
