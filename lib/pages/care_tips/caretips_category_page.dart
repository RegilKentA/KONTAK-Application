import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/caretips_list_item.dart';
import 'package:kontak_application_2/pages/care_tips/firstaid_caretips_subcategory_page.dart';
import 'package:kontak_application_2/pages/care_tips/disaster_caretips_page.dart';
import 'package:kontak_application_2/pages/care_tips/evacuation_caretips_page.dart';

class CareTipsCategoryPage extends StatefulWidget {
  @override
  State<CareTipsCategoryPage> createState() => _CareTipsCategoryPageState();
}

class _CareTipsCategoryPageState extends State<CareTipsCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            'Care Tips',
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
          const SizedBox(height: 5),
          Expanded(
            child: Column(
              children: [
                // First-Aid ListView
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0.0),
                    children: [
                      // first aid list item
                      CaretipsListItem(
                        imagePath: 'assets/images/firstaid_icon.png',
                        text: 'FIRST-AID',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FirstaidCareTipsSubcategoryPage(),
                            ),
                          );
                        },
                        imageWidth: 80,
                        imageHeight: 80,
                      ),
                      // Disaster listitem
                      const SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/disaster_icon.png',
                        text: 'DISASTER\nPREPAREDNESS',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisasterCareTipsPage(),
                            ),
                          );
                        },
                        imageWidth: 80,
                        imageHeight: 80,
                      ),
                      // evactuon listitem
                      const SizedBox(height: 10),
                      CaretipsListItem(
                        imagePath: 'assets/images/evacuation_caretips_icon.png',
                        text: 'EVACUATION\nPLAN',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EvacuationCareTipsPage(),
                            ),
                          );
                        },
                        imageWidth: 80,
                        imageHeight: 80,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
