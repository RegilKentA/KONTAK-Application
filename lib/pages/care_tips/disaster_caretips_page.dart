import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_database.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_model.dart';
import 'package:kontak_application_2/pages/care_tips/disaster_add_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/disaster_caretips_detail_page.dart';

class DisasterCareTipsPage extends StatefulWidget {
  @override
  State<DisasterCareTipsPage> createState() => _DisasterCareTipsPageState();
}

class _DisasterCareTipsPageState extends State<DisasterCareTipsPage> {
  final DatabaseMethodsCareTips _databaseMethods = DatabaseMethodsCareTips();

  bool isAdmin = false; // Variable to track if the user is an admin

  @override
  void initState() {
    super.initState();
    checkUserRole(); // Check user role when the widget is initialized
  }

  Future<void> checkUserRole() async {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Assuming you have a 'users' collection
          .doc(user.uid)
          .get();

      // Check if the user document exists and if the role is 'admin'
      if (userDoc.exists && userDoc['role'] == 'Admin') {
        setState(() {
          isAdmin = true; // Update isAdmin to true
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        leading: CustomBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(
              'assets/images/kontak_logo.png',
              width: 120, // Set the width you want
              height: 54, // Set the height you want
              fit: BoxFit.contain, // Adjust BoxFit as needed
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Text(
            'DISASTER PREPAREDNESS',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Color.fromARGB(255, 116, 116, 116),
                  blurRadius: 2.0,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Expanded(
            child: StreamBuilder<List<DisasterCareTip>>(
              stream: _databaseMethods.getDisasterCareTips(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final disastergetCareTips = snapshot.data!;

                if (disastergetCareTips.isEmpty) {
                  // Show message if no care tips are available
                  return Center(
                    child: Text(
                      'No Disaster Preparedness available.',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: disastergetCareTips.length,
                  itemBuilder: (context, index) {
                    final disastergetCareTip = disastergetCareTips[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DisasterCareTipDetailPage(
                                    disasterCareTip: disastergetCareTip)),
                          );
                        },
                        child: Container(
                          height: 100, // Adjust the height here
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            // Center the content
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.network(
                                    disastergetCareTip.thumbnail,
                                    width: 70, // Set the desired width
                                    height: 70, // Set the desired height
                                    fit:
                                        BoxFit.cover, // Adjust BoxFit as needed
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 70, // Match the width
                                        height: 70, // Match the height
                                        color: Colors
                                            .grey, // Placeholder color for error
                                        child: Icon(Icons.error,
                                            color: Colors.white), // Error icon
                                      );
                                    },
                                  ),
                                  SizedBox(width: 40),
                                  Center(
                                    // Center the text
                                    child: Text(
                                      disastergetCareTip.title,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin // Conditional rendering
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DisasterAddCareTipPage()),
                );
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
            )
          : null, // No FAB if not admin
    );
  }
}
