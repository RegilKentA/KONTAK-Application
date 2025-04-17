import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_database.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_model.dart';
import 'package:kontak_application_2/pages/care_tips/edit_caretips_page.dart';

class FirstAidDetailPage extends StatefulWidget {
  final CareTip careTip;

  FirstAidDetailPage({required this.careTip});

  @override
  _FirstAidDetailPageState createState() => _FirstAidDetailPageState();
}

class _FirstAidDetailPageState extends State<FirstAidDetailPage> {
  final DatabaseMethodsCareTips _databaseMethods = DatabaseMethodsCareTips();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    // Assuming you have a method to get the current user's ID
    final currentUser = FirebaseAuth.instance
        .currentUser; // Replace this with your actual logic to get the user ID

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        userRole =
            userDoc['role']; // Assuming the role is stored under 'role' field
      });
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
                        builder: (context) =>
                            EditCareTipPage(careTip: widget.careTip),
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
                    await _databaseMethods.deleteCareTip(widget.careTip.id);
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
                widget.careTip.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Divider(),
              Text(
                widget.careTip.secondTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              ...widget.careTip.images
                  .map((image) => Image.network(image))
                  .toList(),
              SizedBox(height: 16),
              Text(
                widget.careTip.detailedInfo,
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
