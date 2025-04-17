import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/caretips_list_item.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/services_pages/addeditaddress_page_medical.dart';
import 'package:kontak_application_2/services_pages/addresslist_cbd_page.dart';
import 'package:kontak_application_2/services_pages/addresslist_ab_page.dart';

class MedicalSubcategoryPage extends StatefulWidget {
  final String? selectedCity;

  MedicalSubcategoryPage({this.selectedCity});

  @override
  State<MedicalSubcategoryPage> createState() => _MedicalSubcategoryPageState();
}

class _MedicalSubcategoryPageState extends State<MedicalSubcategoryPage> {
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
                    'assets/images/medical.png',
                    width: 60, // Set the width you want
                    height: 60, // Set the height you want
                    fit: BoxFit.contain, // Adjust BoxFit as needed
                  ),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text(
                        "Medical Subcategory",
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
                      // childbirth delivery
                      CaretipsListItem(
                        imagePath: 'assets/images/childbirth.png',
                        text: 'CHILDBIRTH\nDELIVERY',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddressListChildbirthdeliveryPage(
                                      selectedCity: widget
                                          .selectedCity!), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80,
                        imageHeight: 80,
                      ),
                      // animal bites
                      SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/animal_bites.png',
                        text: 'ANIMAL BITES',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressListAnimalbitesPage(
                                  selectedCity: widget
                                      .selectedCity!), // Replace with your destination page
                            ),
                          );
                        },
                        imageWidth: 80,
                        imageHeight: 80,
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
                      builder: (context) => AddEditAddressPageMedical(
                          selectedCity: widget.selectedCity!)),
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
