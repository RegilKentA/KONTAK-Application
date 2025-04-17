import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/custom_backbutton_white.dart';
import 'package:kontak_application_2/responders/incedentstab_page.dart';
import 'package:kontak_application_2/responders/incidents_reported_tab_page.dart';
import 'package:kontak_application_2/responders/responders_database.dart';

class RespondersDashboardPage extends StatefulWidget {
  @override
  State<RespondersDashboardPage> createState() =>
      _RespondersDashboardPageState();
}

class _RespondersDashboardPageState extends State<RespondersDashboardPage> {
  String? userStationID;
  final RespondentDatabase _firestoredb = RespondentDatabase();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        userStationID = userDoc['userStationID'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: CustomBackButtonWhite(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.green,
          title: const Text(
            'Responders',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditStationDialog();
                }
              },
              icon: const Icon(
                Icons.more_vert, // This is the 3-dot icon
                color: Colors.white,
              ),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.green),
                        SizedBox(width: 10),
                        Text('Edit Station'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Station: $userStationID',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                // const SizedBox(height: 8),
                TabBar(
                  labelStyle:
                      const TextStyle(color: Colors.white, fontSize: 16),
                  unselectedLabelStyle:
                      TextStyle(color: Colors.grey[850], fontSize: 14),
                  tabs: const [
                    Tab(text: 'Active Incidents'),
                    Tab(text: 'Reported Incidents'),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        body: TabBarView(
          children: [
            IncidentsTab(),
            IncidentsReportsTab(),
          ],
        ),
      ),
    );
  }

  // Function to show the Edit Station dialog
  void _showEditStationDialog() {
    final TextEditingController _controller =
        TextEditingController(text: userStationID); // Initial station value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(202, 230, 241, 1),
          title: const Text('Edit Station'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Station Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newStationName = _controller.text;

                if (newStationName.isNotEmpty) {
                  await _firestoredb
                      .saveStation(newStationName); // Save to Firestore
                  setState(() {
                    userStationID = newStationName; // Update the local state
                  });
                }

                Navigator.pop(context); // Close the dialog after saving
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
