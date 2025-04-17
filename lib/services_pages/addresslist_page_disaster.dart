import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/address_listview.dart';
import 'package:kontak_application_2/services_pages/addeditaddress_page_disaster.dart';
import 'package:kontak_application_2/services_pages/address_database.dart';
import 'package:kontak_application_2/services_pages/addressdetail_page_disaster.dart';

class AddressListPageDisaster extends StatefulWidget {
  final String? selectedCity; // Add this parameter

  AddressListPageDisaster({this.selectedCity}); // Constructor with selectedCity

  @override
  _AddressListPageDisasterState createState() =>
      _AddressListPageDisasterState();
}

class _AddressListPageDisasterState extends State<AddressListPageDisaster> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 0), // Adjust padding as needed
              child: Image.asset(
                'assets/images/kontak_logo.png',
                width: 120, // Set the width you want
                height: 54, // Set the height you want
                fit: BoxFit.contain, // Adjust BoxFit as needed
              ),
            ),
          ],
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
                  Icon(
                    Icons.local_police,
                    color: Colors.blue[800],
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Police Category",
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        Database.getAddressStreamDisaster(widget.selectedCity),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No addresses found.'));
                      } else {
                        var addresses = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, index) {
                            var doc = addresses[index];
                            var address = doc.data() as Map<String, dynamic>;
                            var addressId = doc.id;
                            return AddressListTile(
                              addressName: address['name'] ?? 'No Name',
                              destinationPage: AddressDetailPageDisaster(
                                addressId: addressId,
                                selectedCity: widget.selectedCity!,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddEditAddressPageDisaster()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
