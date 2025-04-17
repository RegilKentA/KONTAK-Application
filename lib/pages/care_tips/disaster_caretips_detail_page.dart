import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_database.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_model.dart';
import 'package:kontak_application_2/pages/care_tips/disaster_edit_caretips_page.dart';

class DisasterCareTipDetailPage extends StatefulWidget {
  final DisasterCareTip disasterCareTip;

  DisasterCareTipDetailPage({required this.disasterCareTip});

  @override
  _DisasterCareTipDetailPageState createState() =>
      _DisasterCareTipDetailPageState();
}

class _DisasterCareTipDetailPageState extends State<DisasterCareTipDetailPage> {
  final DatabaseMethodsCareTips _databaseMethods = DatabaseMethodsCareTips();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser; // Get current user

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role']; // Get user role
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 70),
              child: Image.asset(
                'assets/images/kontak_logo.png',
                width: 120,
                height: 54,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        actions: userRole == 'Admin'
            ? [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisasterEditCareTipPage(
                          disasterCareTip: widget.disasterCareTip,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.green,
                  ),
                  onPressed: () async {
                    await _databaseMethods
                        .deleteDisasterCareTip(widget.disasterCareTip.id);
                    Navigator.pop(context);
                  },
                ),
              ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.disasterCareTip.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Divider(),
              Text(
                widget.disasterCareTip.secondTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              // Using a ListView.builder might be a better option if images are too many
              ...widget.disasterCareTip.images.map((image) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0), // Optional: Add space between images
                  child: Image.network(
                    image,
                    height: 650, // Set a height for images
                    width: double
                        .infinity, // Make image take the width of the container
                    fit: BoxFit.contain, // Adjust the fit as needed
                  ),
                );
              }).toList(),
              SizedBox(height: 16),
              Text(
                widget.disasterCareTip.detailedInfo,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
