import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:kontak_application_2/components/custom_backbutton_white.dart';
import 'package:kontak_application_2/services/notification_service.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTimeRange? selectedDateRange;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Define a static list of colors for pie chart
  final List<Color> pieChartColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.pink,
  ];

  Future<QuerySnapshot> _getButtonClicksData() async {
    Query query = FirebaseFirestore.instance.collection('buttonClicks');
    if (selectedDateRange != null) {
      query = query
          .where('timestamp', isGreaterThanOrEqualTo: selectedDateRange!.start)
          .where('timestamp', isLessThanOrEqualTo: selectedDateRange!.end);
    }
    return await query.get();
  }

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
          selectedDateRange =
              DateTimeRange(start: picked.start, end: picked.start);
        } else {
          selectedDateRange = picked;
        }
      });
    }
  }

  Future<void> _exportData() async {
    if (selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date range first')),
      );
      return;
    }

    try {
      // Step 1: Fetch data
      QuerySnapshot buttonClicksSnapshot = await _getButtonClicksData();
      QuerySnapshot incidentSnapshot = await _getIncidentData();

      // Step 2: Process Button Clicks
      Map<String, int> buttonClicksPerStation = {};
      int totalButtonClicks = 0;
      for (var doc in buttonClicksSnapshot.docs) {
        DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
        if (!timestamp.isBefore(selectedDateRange!.start) &&
            !timestamp.isAfter(selectedDateRange!.end)) {
          String stationID = doc['stationID'];
          buttonClicksPerStation[stationID] =
              (buttonClicksPerStation[stationID] ?? 0) + 1;
          totalButtonClicks++;
        }
      }

      // Step 3: Process Incidents
      int totalIncidents = 0;
      List<List<dynamic>> incidentData = [];
      for (var doc in incidentSnapshot.docs) {
        DateTime dateTime = (doc['date_time'] as Timestamp).toDate();
        if (!dateTime.isBefore(selectedDateRange!.start) &&
            !dateTime.isAfter(selectedDateRange!.end)) {
          String formattedDateTime =
              '${dateTime.year}-${dateTime.month}-${dateTime.day},\n${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
          String name = doc['user_name'];
          String stationCalled = doc['station_id'];
          String status = doc['status'];
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
          totalIncidents++;
        }
      }

      // Step 4: Create PDF
      final pdf = pw.Document();

      // Add button click data
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Total Button Clicks: $totalButtonClicks',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Button Clicks Data',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Station ID', 'Button Clicks'],
              data: buttonClicksPerStation.entries
                  .map((entry) => [entry.key, entry.value])
                  .toList(),
            ),
          ],
        ),
      ));

      // Add incident data
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Total Incidents: $totalIncidents',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Incident Data',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ));

      // Step 5: Ask user to pick a folder to save PDF
      String? directoryPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose folder to save the report',
      );

      if (directoryPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export canceled by user.')),
        );
        return;
      }

      // Step 6: Save the PDF
      String filePath = p.join(directoryPath, 'analytics_data.pdf');
      File file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Step 7: Notify user
      await NotificationService.showNotification(
        title: "Export Complete",
        body: "PDF saved to:\n$filePath",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to: $filePath')),
      );
    } catch (e) {
      print('Export error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        leading: CustomBackButtonWhite(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Analytics',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF18A54A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection
            Text(
              'Date Selection:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Date range selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF18A54A),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: InkWell(
                      onTap: () =>
                          _selectDateRange(context), // Tap to open date picker
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Space out title and icon
                          children: [
                            Text(
                              selectedDateRange == null
                                  ? 'Select Date Range'
                                  : '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}',
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
                              Icons.calendar_today,
                              color:
                                  Colors.white, // Set the icon color to white
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Export button below Date Range selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
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
                ),
              ],
            ),

            SizedBox(height: 20),
            // Total Call Button Clicks Section
            Text(
              'Total Call Button Clicks:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<QuerySnapshot>(
              future: _getButtonClicksData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error loading data: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                int totalClicks = snapshot.data?.docs.length ?? 0;

                // Process data for the pie chart
                Map<String, int> clicksPerStation = {};
                for (var doc in snapshot.data!.docs) {
                  String stationID = doc['stationID'];
                  clicksPerStation[stationID] =
                      (clicksPerStation[stationID] ?? 0) + 1;
                }

                // Generate colors and prepare pie chart data
                List<PieChartSectionData> pieSections = [];
                int colorIndex = 0;

                clicksPerStation.forEach((station, count) {
                  Color color =
                      pieChartColors[colorIndex % pieChartColors.length];
                  double percentage = (count / totalClicks) * 100;

                  pieSections.add(
                    PieChartSectionData(
                      value: count.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: color,
                      radius: 120,
                      titleStyle:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                  colorIndex++;
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '$totalClicks',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF18A54A),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Clicks Per Station Type:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 330,
                      child: PieChart(
                        PieChartData(
                          sections: pieSections,
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Legend
                    Text(
                      'Legend:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: clicksPerStation.entries.map((entry) {
                        Color color = pieChartColors[
                            clicksPerStation.keys.toList().indexOf(entry.key) %
                                pieChartColors.length];
                        return Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: color,
                            ),
                            SizedBox(width: 8),
                            Text(entry.key),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 40), // Space between sections
            // Total Reported Incidents Section
            Text(
              'Total Reported Incidents:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<QuerySnapshot>(
              future: _getIncidentData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error loading reported incidents: ${snapshot.error}'));
                }

                int totalReported = snapshot.data?.docs.length ?? 0;

                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$totalReported',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18A54A),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
