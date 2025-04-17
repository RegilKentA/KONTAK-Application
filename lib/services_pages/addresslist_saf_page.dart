import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/address_listview.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/services_pages/address_database.dart';
import 'package:kontak_application_2/services_pages/addressdetail_page_accidents.dart';

class AddressListSlipandfallAccidentsPage extends StatefulWidget {
  final String? selectedCity;

  AddressListSlipandfallAccidentsPage({this.selectedCity});

  @override
  _AddressListSlipandfallAccidentsPageState createState() =>
      _AddressListSlipandfallAccidentsPageState();
}

class _AddressListSlipandfallAccidentsPageState
    extends State<AddressListSlipandfallAccidentsPage> {
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
                    'assets/images/slipandfall.png',
                    width: 60, // Set the width you want
                    height: 60, // Set the height you want
                    fit: BoxFit.contain, // Adjust BoxFit as needed
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Slip and Fall Accidents",
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
                    stream: Database.getAddressStreamSlipandfallAccidents(
                        widget.selectedCity),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                            child: Text('No emergency station found.'));
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
                              destinationPage: AddressDetailPageAccidents(
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
    );
  }
}
