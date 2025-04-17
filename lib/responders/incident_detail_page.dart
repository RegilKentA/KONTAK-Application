import 'package:flutter/material.dart';
import 'package:kontak_application_2/responders/emergency_incident.dart';
import 'package:kontak_application_2/responders/responders_database.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IncidentDetailsPage extends StatefulWidget {
  final EmergencyIncident incident;

  IncidentDetailsPage({required this.incident});

  @override
  _IncidentDetailsPageState createState() => _IncidentDetailsPageState();
}

class _IncidentDetailsPageState extends State<IncidentDetailsPage> {
  final TextEditingController _descriptionController = TextEditingController();
  LatLng? _userLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    // Fetch the latitude and longitude from your database
    final location = await RespondentDatabase()
        .getUserLocation(widget.incident.referenceNumber);
    if (location != null) {
      setState(() {
        _userLocation = LatLng(location.latitude, location.longitude);
      });
    }
  }

  void _generateReport() async {
    final report = {
      'referenceNumber': widget.incident.referenceNumber,
      'description': _descriptionController.text,
      'dateTime': widget.incident.dateTime,
      'userName': widget.incident.name,
    };

    try {
      await RespondentDatabase().updateIncidentWithDescription(
        widget.incident.referenceNumber,
        _descriptionController.text,
      );

      await RespondentDatabase()
          .markIncidentAsReported(widget.incident.referenceNumber);
      Navigator.pop(context);
      print(
          'Report generated, description saved, and incident marked as reported: $report');
    } catch (e) {
      print('Error generating report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        title: Text(
          'Incident Details',
          style: TextStyle(color: Colors.green),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.green,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        // Add SingleChildScrollView here
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(widget.incident.profilePictureUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              'Name: ${widget.incident.name.isNotEmpty ? widget.incident.name : 'No Name'}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Reference ID: ${widget.incident.referenceNumber}'),
            Text(
                'Date & Time: ${DateFormat.yMMMd().add_jm().format(widget.incident.dateTime)}'),
            Text('Address: ${widget.incident.address}'),
            Text('Contact: ${widget.incident.contactNumber}'),
            SizedBox(height: 16),
            Text("User's location:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (_userLocation != null)
              Container(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLocation!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('userLocation'),
                      position: _userLocation!,
                    ),
                  },
                ),
              ),
            SizedBox(height: 16),
            Text('Description/Report:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter description here...',
              ),
            ),
            SizedBox(height: 16), // Add some spacing before the button
            Center(
              child: _isLoading // Show loading indicator or button
                  ? CircularProgressIndicator() // Show loading indicator
                  : ElevatedButton(
                      onPressed: _generateReport,
                      child: Text('Generate Report',
                          style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
