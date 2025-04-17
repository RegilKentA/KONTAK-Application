import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/caretips_list_item.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/services_pages/addeditaddress_page_disaster.dart';
import 'package:kontak_application_2/services_pages/addresslist_eq_page.dart';
import 'package:kontak_application_2/services_pages/addresslist_flood_page.dart';
import 'package:kontak_application_2/services_pages/addresslist_ls_page.dart';

class DisasterSubcategoryPage extends StatefulWidget {
  final String? selectedCity;

  DisasterSubcategoryPage({this.selectedCity});

  @override
  State<DisasterSubcategoryPage> createState() =>
      _DisasterSubcategoryPageState();
}

class _DisasterSubcategoryPageState extends State<DisasterSubcategoryPage> {
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
      if (userDoc.exists) {
        // Check if the role is 'admin'
        if (userDoc['role'] == 'Admin') {
          setState(() {
            isAdmin = true;
          });
        }

        // Check if selectedCity matches adminMunicipality
        if (userDoc['role'] == 'Sub-Admin' &&
            widget.selectedCity == userDoc['adminMunicipality']) {
          setState(() {
            isAdmin = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        leading: CustomBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/kontak_logo.png',
                  width: 120,
                  height: 54,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFCAE6F1),
        height: height,
        width: width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/disaster_icon.png',
                    width: 60, // Set the width you want
                    height: 60, // Set the height you want
                    fit: BoxFit.contain, // Adjust BoxFit as needed
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        "Disaster Subcategory",
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(128, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ListView(
                    // Removed the inner Expanded widget
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0.0),
                    children: [
                      // earthquake
                      CaretipsListItem(
                        imagePath: 'assets/images/earthquake.png',
                        text: 'EARTHQUAKE',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressListEarthquakePage(
                                  selectedCity: widget
                                      .selectedCity!), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 90,
                        imageHeight: 90,
                      ),
                      // flood
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/flood.png',
                        text: 'FLOOD',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressListFloodPage(
                                  selectedCity: widget
                                      .selectedCity!), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 90,
                        imageHeight: 90,
                      ),
                      // landslide
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/landslide.png',
                        text: 'LANDSLIDE',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressListLandslidePage(
                                  selectedCity: widget
                                      .selectedCity!), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 85,
                        imageHeight: 85,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin // Conditional rendering
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddEditAddressPageDisaster(
                            selectedCity: widget.selectedCity!,
                          )),
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
