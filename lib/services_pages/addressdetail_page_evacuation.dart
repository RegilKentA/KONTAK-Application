import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kontak_application_2/components/addressdetail_appbar.dart';
import 'package:kontak_application_2/services/call_service.dart';
import 'package:kontak_application_2/services/permission_service.dart';
import 'package:kontak_application_2/services_pages/addeditaddress_page_evacuation.dart';
import 'package:kontak_application_2/services_pages/address_database.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class AddressDetailPageEvacuation extends StatefulWidget {
  final String addressId;
  final String selectedCity;

  AddressDetailPageEvacuation({
    required this.addressId,
    required this.selectedCity,
  });

  @override
  _AddressDetailPageEvacuationState createState() =>
      _AddressDetailPageEvacuationState();
}

class _AddressDetailPageEvacuationState
    extends State<AddressDetailPageEvacuation> {
  final CallService callService = CallService();

  bool _isCallPermissionGranted = false;
  bool _isLocationPermissionGranted = false;
  bool _isLoading = false;

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check if the phone permission is granted
    bool callPermission = await PermissionsService.checkPhonePermission();

    // Check if location permission is granted
    bool locationPermission =
        await PermissionsService.checkLocationPermission();

    // Handle the case where call permission is not granted
    if (!callPermission) {
      callPermission = await PermissionsService.requestPhonePermission();
    }

    // Handle the case where location permission is not granted
    if (!locationPermission) {
      locationPermission = await PermissionsService.requestLocationPermission();
    }

    setState(() {
      _isCallPermissionGranted = callPermission;
      _isLocationPermissionGranted = locationPermission;
    });

    // If the call permission is permanently denied
    if (!callPermission) {
      bool isPhonePermanentlyDenied =
          await PermissionsService.isPhonePermissionPermanentlyDenied();
      if (isPhonePermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Please enable call permissions in the app settings.'),
            action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () async {
                  openAppSettings();
                }),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Call permission is required to make the call.')),
        );
      }
    }

    // If the location permission is permanently denied
    if (!locationPermission) {
      bool isLocationPermanentlyDenied =
          await PermissionsService.isLocationPermissionPermanentlyDenied();
      if (isLocationPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Please enable location permissions in the app settings.'),
            action: SnackBarAction(
                label: 'Open Settings',
                onPressed: () async {
                  openAppSettings();
                }),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Location permission is required for this feature.')),
        );
      }
    }
  }

  Future<void> _makeCall(
      String number, String stationID, String stationType) async {
    if (_isCallPermissionGranted && _isLocationPermissionGranted) {
      setState(() {
        _isLoading = true;
      });

      var userDetailsFuture = Database.getUserDocument(currentUser!.uid);
      var positionFuture =
          Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      var results = await Future.wait([userDetailsFuture, positionFuture]);
      var userDetails = results[0] as Map<String, dynamic>;
      Position currentPosition = results[1] as Position;

      Database.recordButtonClick(currentUser!.uid, stationType)
          .catchError((error) {});

      await FlutterPhoneDirectCaller.callNumber(number);

      await Future.delayed(Duration(seconds: 3));

      _startListening(userDetails, currentPosition, number, stationID);

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (!_isCallPermissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Call permission is required to make the call.')),
        );
      } else if (!_isLocationPermissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Location permission is required for this feature.')),
        );
      }
    }
  }

  void _startListening(Map<String, dynamic> userDetails, Position position,
      String number, String stationID) {
    String userId = currentUser!.uid;
    String name = userDetails['name'] ?? "No Name";

    String address =
        "${userDetails['addressLine1'] ?? ''}, ${userDetails['addressLine2'] ?? ''}, ${userDetails['city'] ?? ''}, ${userDetails['province'] ?? ''}, ${userDetails['postalCode'] ?? ''}"
            .trim();

    if (address.endsWith(',')) {
      address =
          address.substring(0, address.length - 1); // Remove trailing comma
    }

    String phone = userDetails['contact'] ?? "No Phone";
    String profilepic =
        userDetails['profilePictureUrl'] ?? "No Profile Picture";

    callService.startListening(
      (String status) {
        print("Call state changed: $status");
      },
      number,
      userId,
      name,
      address,
      phone,
      profilepic,
      null,
      position.latitude,
      position.longitude,
      stationID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: FutureBuilder<Map<String, dynamic>?>(
              // Fetch user data
              future: Database.getUserDocument(currentUser!.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context)
                        .size
                        .height, // Ensure it's full height
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                } else if (!userSnapshot.hasData ||
                    userSnapshot.data!.isEmpty) {
                  return const Center(child: Text('User not found.'));
                }

                var userDoc = userSnapshot.data!;
                bool isAdmin = userDoc['role'] == 'Admin' ||
                    (userDoc['role'] == 'Sub-Admin' &&
                        widget.selectedCity == userDoc['adminMunicipality']);

                return StreamBuilder<DocumentSnapshot>(
                  // Fetch fire station data
                  stream: Database.getAddressStreamByIdEvacuation(
                      widget.addressId, widget.selectedCity),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: MediaQuery.of(context)
                            .size
                            .height, // Ensure it's full height
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text('Address not found.'));
                    } else {
                      var document = snapshot.data!;
                      var address = document.data() as Map<String, dynamic>;

                      double? latitude = address['latitude'] is num
                          ? (address['latitude'] as num).toDouble()
                          : null;
                      double? longitude = address['longitude'] is num
                          ? (address['longitude'] as num).toDouble()
                          : null;

                      if (latitude == null || longitude == null) {
                        return const Center(
                            child: Text(
                                'Latitude or Longitude data is not available.'));
                      }

                      String stationID = address['name'];
                      String? name = address['name'];
                      String addressLine1 = address['addressLine1'];
                      String addressLine2 = address['addressLine2'];
                      String city = address['city'];
                      String province = address['province'];
                      String postalCode = address['postalCode'];
                      String addressField =
                          '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}, $city, $province, $postalCode';
                      String? telephone = address['telephone'];
                      String? cellphone = address['cellphone'];
                      String? thumbnailUrl = address['thumbnail'];
                      String stationType = address['stationType'];

                      return Column(
                        children: [
                          AddressdetailAppbarMain(
                            thumbnailUrl: thumbnailUrl,
                            iconColor: Colors.yellow[800],
                            label: "EVACUATION",
                            addressId: widget.addressId,
                            selectedCity: widget.selectedCity,
                            isAdmin: isAdmin,
                            onEdit: isAdmin
                                ? (String id, String city) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEditAddressPageEvacuation(
                                                addressId: id,
                                                selectedCity: city),
                                      ),
                                    );
                                  }
                                : null,
                            onDelete: isAdmin
                                ? (String id, String city) {
                                    Database.deleteAddressEvacuation(id, city);
                                    Navigator.pop(context);
                                  }
                                : null,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "SERVICE LOCATOR",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Container(
                            height: 250,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(latitude, longitude),
                                  zoom: 15),
                              markers: {
                                Marker(
                                  markerId: MarkerId(widget.addressId),
                                  position: LatLng(latitude, longitude),
                                ),
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            title: const Text('Station Name:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text(name ?? 'No Name'),
                          ),
                          ListTile(
                            title: const Text('Address:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text(addressField),
                          ),
                          ListTile(
                            title: const Text('Telephone Number:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text(telephone ?? 'No Telephone'),
                          ),
                          ListTile(
                            title: const Text('Cellphone Number:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text(cellphone ?? 'No Cellphone'),
                          ),
                          if ((_isCallPermissionGranted &&
                                  _isLocationPermissionGranted) &&
                              (telephone != null || cellphone != null)) ...[
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (telephone != null) ...[
                                    buildCallButton(context, telephone,
                                        currentUser!, stationID, stationType),
                                  ],
                                  const SizedBox(width: 20),
                                  if (cellphone != null) ...[
                                    buildCallButton(context, cellphone,
                                        currentUser!, stationID, stationType,
                                        isCellphone: true),
                                  ],
                                ],
                              ),
                            ),
                          ] else if ((!_isCallPermissionGranted &&
                                  !_isLocationPermissionGranted) ||
                              (_isCallPermissionGranted &&
                                  !_isLocationPermissionGranted) ||
                              (!_isCallPermissionGranted &&
                                  _isLocationPermissionGranted)) ...[
                            const Center(
                                child: Text(
                                    'Call permission or location permission are denied.')),
                          ],
                        ],
                      );
                    }
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true, // This makes the content unclickable
                child: Container(
                  color: Colors.black54, // Semi-transparent modal barrier
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildCallButton(BuildContext context, String number, User currentUser,
      String stationID, String stationType,
      {bool isCellphone = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            onPressed: () {
              if (!_isLoading) {
                _makeCall(number, stationID, stationType);
              }
            },
            child: Icon(isCellphone ? Icons.phone_android : Icons.call,
                color: Colors.white),
            backgroundColor: Color(0xFF18A54A),
            shape: CircleBorder(),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          isCellphone ? 'Cellphone\nNumber' : 'Telephone\nNumber',
          textAlign: TextAlign.center,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
