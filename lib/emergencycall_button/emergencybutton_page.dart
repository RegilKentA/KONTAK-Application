import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';
import 'package:kontak_application_2/emergencycall_button/services.dart';
import 'package:kontak_application_2/services/call_service.dart';
import 'package:kontak_application_2/services/permission_service.dart';
import 'package:kontak_application_2/services_pages/address_database.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencybuttonPage extends StatefulWidget {
  @override
  _EmergencybuttonPageState createState() => _EmergencybuttonPageState();
}

class _EmergencybuttonPageState extends State<EmergencybuttonPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<DocumentSnapshot> _nearbyAddresses = [];
  Map<MarkerId, Marker> _markers = {};
  AddressService _addressService = AddressService();
  LocationService _locationService = LocationService();
  bool _isLoading = true;
  bool _isLoadingg = true;
  bool _isCallPermissionGranted = false;
  bool _isLocationPermissionGranted = false;

  final CallService callService = CallService();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      // Ensure location permission is granted before fetching location
      bool hasLocationPermission = await Permission.location.isGranted;

      if (hasLocationPermission) {
        Position position = await _locationService.getCurrentLocation();
        Future.microtask(() {
          setState(() {
            _currentPosition = position;
            _isLoading = false;
          });
          _addCurrentLocationMarker();
          _fetchNearbyAddresses(position);
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Optionally, you can ask for permission here or show a message to the user
      }
    } catch (e) {
      print("Error fetching location: $e");
      Future.microtask(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  // Request permissions for call and location
  Future<void> _requestPermissions() async {
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

  void _addCurrentLocationMarker() {
    if (_currentPosition != null) {
      final markerId = MarkerId('currentLocation');
      final marker = Marker(
        markerId: markerId,
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );

      setState(() {
        _markers[markerId] = marker;
      });
    }
  }

  Future<void> _fetchNearbyAddresses(Position position) async {
    try {
      // _isLoadingg = true;
      List<DocumentSnapshot> addresses =
          await _addressService.getNearbyAddresses(position, 5.0);
      setState(() {
        _isLoadingg = false;
        _nearbyAddresses = addresses;
        _addNearbyAddressMarkers();
      });
    } catch (e) {
      print("Error fetching nearby addresses: $e");
    }
  }

  void _addNearbyAddressMarkers() {
    for (var doc in _nearbyAddresses) {
      _addAddressMarker(doc);
    }
  }

  void _addAddressMarker(DocumentSnapshot doc) {
    double latitude = doc['latitude'];
    double longitude = doc['longitude'];
    final markerId = MarkerId(doc.id);
    final marker = Marker(
      markerId: markerId,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: doc['name']),
    );

    setState(() {
      _markers[markerId] = marker;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController?.moveCamera(CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ));
    }
  }

  void _onAddressTap(DocumentSnapshot doc) {
    double latitude = doc['latitude'];
    double longitude = doc['longitude'];

    if (_currentPosition != null) {
      LatLng currentLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      LatLng addressLatLng = LatLng(latitude, longitude);

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(currentLatLng.latitude, addressLatLng.latitude),
          min(currentLatLng.longitude, addressLatLng.longitude),
        ),
        northeast: LatLng(
          max(currentLatLng.latitude, addressLatLng.latitude),
          max(currentLatLng.longitude, addressLatLng.longitude),
        ),
      );

      _mapController
          ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
    }
  }

  void _makePhoneCall(
      String contact, String stationID, String stationType) async {
    if (_isCallPermissionGranted && _isLocationPermissionGranted) {
      setState(() {
        _isLoading = true;
      });

      // Get user details and position for tracking
      var userDetailsFuture =
          Database.getUserDocument(FirebaseAuth.instance.currentUser!.uid);
      var positionFuture =
          Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      var results = await Future.wait([userDetailsFuture, positionFuture]);
      var userDetails = results[0] as Map<String, dynamic>;
      Position currentPosition = results[1] as Position;

      // Start the phone call directly
      await FlutterPhoneDirectCaller.callNumber(contact);

      // Log the button click in the database
      Database.recordButtonClick(
              FirebaseAuth.instance.currentUser!.uid, stationType)
          .catchError((error) {});

      setState(() {
        _isLoading = false;
      });

      // Start listening to the call
      _startListening(userDetails, currentPosition, contact, stationID);
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
      String contact, String stationID) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
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

    // Start call listening
    callService.startListening(
      (String status) {
        print("Call state changed: $status");
      },
      contact,
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
      appBar: AppBar(
        leading: CustomBackButton(onPressed: () => Navigator.pop(context)),
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/kontak_loc_logo.png', height: 50),
                Text('KONTAK Locator', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),

        // centerTitle: true,
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? Center(child: Text("Unable to fetch current location"))
              : !_isCallPermissionGranted
                  ? Center(
                      child:
                          Text("Call permission is required for this feature"))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Service Locator',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude),
                              zoom: 15,
                            ),
                            markers: Set<Marker>.of(_markers.values),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Nearby Addresses within 5km',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: _isLoadingg
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                )
                              : _nearbyAddresses.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No emergency addresses found within 5km.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700]),
                                      ),
                                    )
                                  : ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 10.0),
                                      itemCount: _nearbyAddresses.length,
                                      itemBuilder: (context, index) {
                                        DocumentSnapshot doc =
                                            _nearbyAddresses[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ListTile(
                                                leading: doc['thumbnail'] !=
                                                            null &&
                                                        doc['thumbnail']
                                                            .isNotEmpty
                                                    ? ClipOval(
                                                        child: Image.network(
                                                          doc['thumbnail'],
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Container(
                                                              width: 40,
                                                              height: 40,
                                                              color:
                                                                  Colors.grey,
                                                              child: Icon(
                                                                  Icons.error,
                                                                  color: Colors
                                                                      .white),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : null,
                                                title: Text(
                                                  doc['name'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (doc['telephone'] !=
                                                            null &&
                                                        doc['telephone']
                                                            .isNotEmpty)
                                                      IconButton(
                                                        icon: Icon(Icons.phone,
                                                            color: Colors.white,
                                                            size: 40),
                                                        onPressed: () =>
                                                            _makePhoneCall(
                                                                doc['telephone'],
                                                                doc['name'],
                                                                doc['stationType']),
                                                      ),
                                                    if (doc['cellphone'] !=
                                                            null &&
                                                        doc['cellphone']
                                                            .isNotEmpty)
                                                      IconButton(
                                                        icon: Icon(
                                                            Icons.phone_android,
                                                            color: Colors
                                                                .grey[200],
                                                            size: 40),
                                                        onPressed: () =>
                                                            _makePhoneCall(
                                                                doc['cellphone'],
                                                                doc['name'],
                                                                doc['stationType']),
                                                      ),
                                                  ],
                                                ),
                                                onTap: () => _onAddressTap(doc),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
    );
  }
}
