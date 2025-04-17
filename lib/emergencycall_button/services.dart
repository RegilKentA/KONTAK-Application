import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current location
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}

class AddressService {
  final List<String> addressCollections = [
    'fire_addresses',
    'accidents_addresses',
    'disaster_addresses',
    'medical_addresses',
    'police_addresses',
    'evacuation_addresses',
  ];

  Future<List<DocumentSnapshot>> getAllAddresses() async {
    Set<String> uniqueAddressIds = {};
    List<DocumentSnapshot> allAddresses = [];

    // Fetch all cities
    QuerySnapshot citiesSnapshot =
        await FirebaseFirestore.instance.collection('cities').get();

    List<Future> fetchFutures = [];
    for (var cityDoc in citiesSnapshot.docs) {
      for (String collection in addressCollections) {
        fetchFutures.add(
          FirebaseFirestore.instance
              .collection('cities')
              .doc(cityDoc.id)
              .collection(collection)
              .get()
              .then((snapshot) {
            for (var doc in snapshot.docs) {
              if (!uniqueAddressIds.contains(doc.id)) {
                allAddresses.add(doc);
                uniqueAddressIds.add(doc.id);
              }
            }
          }),
        );
      }
    }

    await Future.wait(fetchFutures);
    return allAddresses;
  }

  Future<List<DocumentSnapshot>> getNearbyAddresses(
      Position userPosition, double radiusInKm) async {
    List<DocumentSnapshot> nearbyAddresses = [];

    // Fetch all addresses first
    List<DocumentSnapshot> allAddresses = await getAllAddresses();

    // Filter addresses to find nearby ones
    nearbyAddresses =
        _filterNearbyAddresses(allAddresses, userPosition, radiusInKm);

    return nearbyAddresses;
  }

  List<DocumentSnapshot> _filterNearbyAddresses(
      List<DocumentSnapshot> docs, Position userPosition, double radiusInKm) {
    List<DocumentSnapshot> nearbyAddresses = [];

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>?;

      // Validate the document data
      if (_isValidAddressData(data)) {
        try {
          double latitude = data!['latitude'].toDouble();
          double longitude = data['longitude'].toDouble();
          double distance = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            latitude,
            longitude,
          );

          if (distance <= radiusInKm * 1000) {
            nearbyAddresses.add(doc);
          }
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
        }
      }
    }

    return nearbyAddresses;
  }

  bool _isValidAddressData(Map<String, dynamic>? data) {
    if (data == null ||
        !data.containsKey('latitude') ||
        !data.containsKey('longitude')) {
      print('Invalid document data: ${data?.toString()}');
      return false;
    }
    return true;
  }
}
