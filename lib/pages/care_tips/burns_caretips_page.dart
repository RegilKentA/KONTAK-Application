import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_database.dart';
import 'package:kontak_application_2/pages/care_tips/firstaid_detail_page.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_model.dart';

class BurnsCareTipsPage extends StatefulWidget {
  @override
  State<BurnsCareTipsPage> createState() => _BurnsCareTipsPageState();
}

class _BurnsCareTipsPageState extends State<BurnsCareTipsPage> {
  final DatabaseMethodsCareTips _databaseMethods = DatabaseMethodsCareTips();

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
            'BURNS',
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
            child: StreamBuilder<List<CareTip>>(
              stream: _databaseMethods.getCareTips(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Filter care tips to only include those with the subcategory "Burns"
                final careTips = snapshot.data!
                    .where((careTip) => careTip.subcategory == "Burns")
                    .toList();

                if (careTips.isEmpty) {
                  return Center(
                      child: Text("No care tips available for Burns."));
                }

                return ListView.builder(
                  itemCount: careTips.length,
                  itemBuilder: (context, index) {
                    final careTip = careTips[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FirstAidDetailPage(careTip: careTip)),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  careTip.thumbnail,
                                  width: 70, // Set the desired width
                                  height: 70, // Set the desired height
                                  fit: BoxFit.cover, // Adjust BoxFit as needed
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
                                SizedBox(width: 20),
                                Center(
                                  // Center the text
                                  child: Text(
                                    careTip.title,
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
