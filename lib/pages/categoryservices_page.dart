import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/services_pages/accidents_subcategory_page.dart';
import 'package:kontak_application_2/services_pages/disaster_subcategory_page.dart';
import 'package:kontak_application_2/services_pages/medical_subcategory_page.dart';
import 'package:kontak_application_2/services_pages/addresslist_page_evacuation.dart';
import 'package:kontak_application_2/services_pages/addresslist_page_fire.dart';
import 'package:kontak_application_2/services_pages/addresslist_page_police.dart';

class CategoryServices extends StatefulWidget {
  const CategoryServices({super.key});

  @override
  State<CategoryServices> createState() => _CategoryServicesState();
}

class _CategoryServicesState extends State<CategoryServices> {
  String? _selectedCity;
  final List<String> _cities = [
    'Alfonso',
    'Amadeo',
    'Bacoor',
    'Carmona',
    'Cavite City',
    'Dasmariñas',
    'General Emilio Aguinaldo',
    'General Mariano Alvarez',
    'General Trias',
    'Imus',
    'Indang',
    'Kawit',
    'Magallanes',
    'Maragondon',
    'Mendez',
    'Naic',
    'Noveleta',
    'Rosario',
    'Silang',
    'Tagaytay',
    'Tanza',
    'Ternate',
    'Trece Martires'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserCity();
  }

  // Function to load the user's city from Firestore
  void _loadUserCity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the user's Firestore document reference
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc = await userRef.get();

      // Check if the city field exists and update the selected city
      if (userDoc.exists && userDoc['city'] != null) {
        // If the city is available in the document, set it as the selected city
        setState(() {
          _selectedCity = userDoc['city'];
        });
      } else {
        // If the city is not found, set to the default city (e.g., 'General Trias')
        setState(() {
          _selectedCity = _cities[22];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      // Replace the current Column with a GridView.builder
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCity,
              hint: const Text('Select City'),
              items: _cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCity = value;
                  });
                }
              },
              isExpanded: true,
            ),
            const SizedBox(height: 16.0),

            // Using GridView.builder to display 2 columns and 3 rows
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row
                    crossAxisSpacing: 16.0, // Horizontal space between items
                    mainAxisSpacing: 16.0, // Vertical space between items
                    childAspectRatio:
                        1.0, // Adjust to make sure the items maintain a square shape
                  ),
                  itemCount: 6, // 6 items in total (2 columns, 3 rows)
                  itemBuilder: (context, index) {
                    // Depending on the index, display a different category
                    switch (index) {
                      case 0:
                        return _buildCategoryContainer(
                          context,
                          'assets/images/fire_icon.png',
                          'FIRE',
                          (selectedCity) =>
                              AddressListPageFire(selectedCity: selectedCity),
                        );
                      case 1:
                        return _buildCategoryContainer(
                          context,
                          'assets/images/police_icon.png',
                          'POLICE',
                          (selectedCity) =>
                              AddressListPagePolice(selectedCity: selectedCity),
                        );
                      case 2:
                        return _buildCategoryContainer(
                          context,
                          'assets/images/medical.png',
                          'MEDICAL',
                          (selectedCity) => MedicalSubcategoryPage(
                              selectedCity: selectedCity),
                        );
                      case 3:
                        return _buildCategoryContainer(
                          context,
                          'assets/images/evacuation_icon.png',
                          'EVACUATION',
                          (selectedCity) => AddressListPageEvacuation(
                              selectedCity: selectedCity),
                        );
                      case 4:
                        return _buildCategoryContainer(
                          context,
                          'assets/images/disaster_icon.png',
                          'DISASTER',
                          (selectedCity) => DisasterSubcategoryPage(
                              selectedCity: selectedCity),
                        );
                      case 5:
                        return _buildCategoryContainer(
                          context,
                          'assets/images/accidents_icon.png',
                          'ACCIDENTS',
                          (selectedCity) => AccidentsSubcategoryPage(
                              selectedCity: selectedCity),
                        );
                      default:
                        return Container(); // Fallback for any invalid index
                    }
                  },
                ),
              ),
            ),
            // const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  // Helper function to build category containers
  Widget _buildCategoryContainer(
    BuildContext context,
    String imagePath,
    String categoryTitle,
    Widget Function(String? selectedCity) nextPage,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => nextPage(_selectedCity),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xff18A54A),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adjust image size based on screen width
            Image.asset(
              imagePath,
              width: MediaQuery.of(context).size.width *
                  0.25, // 25% of screen width
              height:
                  MediaQuery.of(context).size.width * 0.25, // Keep aspect ratio
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8.0),
            Text(
              categoryTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width > 600
                    ? 22
                    : 18, // Adjust text size for smaller screens
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
