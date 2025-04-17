import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/caretips_list_item.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/pages/care_tips/firstaid_add_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/bandaging_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/bites_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/burns_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/minorcutswounds_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/fracture_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/heartattack_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/heatstroke_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/poisoning_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/stroke_caretips_page.dart';

class FirstaidCareTipsSubcategoryPage extends StatefulWidget {
  @override
  State<FirstaidCareTipsSubcategoryPage> createState() =>
      _FirstaidCareTipsSubcategoryPageState();
}

class _FirstaidCareTipsSubcategoryPageState
    extends State<FirstaidCareTipsSubcategoryPage> {
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
            'FIRST-AID SUBCATEGORY',
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
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 0.0), // Set vertical padding to 0
                    children: [
                      // burns
                      CaretipsListItem(
                        imagePath: 'assets/images/burns_icon.png',
                        text: 'BURNS',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BurnsCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // fracture
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/fracture_icon.png',
                        text: 'FRACTURE',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FractureCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // poisoning
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/foodpoisoning.png',
                        text: 'POISONING',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PoisoningCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // Bites
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/animal_bites.png',
                        text: 'BITES',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BitesCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // stroke listitem
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/stroke_icon.png',
                        text: 'STROKE',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StrokeCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // heat stroke listitem
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/heatstroke_icon.png',
                        text: 'HEAT STROKE',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HeatstrokeCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // heart attack listitem
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/heartattack_icon.png',
                        text: 'HEART ATTACK',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HeartattackCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // wound listitem
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/wounds.png',
                        text: 'MINOR CUTS\nAND WOUNDS',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MinorcutsWoundsCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),
                      // bandaging listitem
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/handbandaging_icon.png',
                        text: 'BANDAGING',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BandagingCareTipsPage(), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80, // Specify the width you want
                        imageHeight: 80, // Specify the height you want
                      ),

                      SizedBox(height: 50)
                    ],
                  ),
                ),
              ],
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
                      builder: (context) => FirstAidAddCareTipPage()),
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
