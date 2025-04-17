import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  // records number of clicks in call
  static Future<void> recordButtonClick(String userId, String stationID) async {
    try {
      // Assuming you have a Firestore instance initialized
      CollectionReference clicksCollection =
          FirebaseFirestore.instance.collection('buttonClicks');

      await clicksCollection.add({
        'userId': userId,
        'stationID': stationID,
        'timestamp': FieldValue.serverTimestamp(), // Save timestamp
      });
      print("Button click recorded successfully.");
    } catch (e) {
      print("Error recording button click: $e");
    }
  }

  // fetch user details
  static Future<Map<String, dynamic>> getUserDetails(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  // New for role
  static Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error fetching user document: $e');
    }
    return null;
  }

  // Fetch user role from Firestore
  static Future<String?> getUserRole(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? data =
            userSnapshot.data() as Map<String, dynamic>?;
        return data?['Role'] as String?;
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
    return null;
  }

  // stream each addresses
  static Stream<QuerySnapshot> getAddressStreamFire(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('fire_addresses')
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamAccidents() {
    return FirebaseFirestore.instance
        .collection('accidents_addresses')
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamVehicularAccidents(
      String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('accidents_addresses')
        .where('subcategory', isEqualTo: 'VEHICULAR') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamDrowningAccidents(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('accidents_addresses')
        .where('subcategory', isEqualTo: 'DROWNING') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamElectricalAccidents(
      String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('accidents_addresses')
        .where('subcategory', isEqualTo: 'ELECTRICAL') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamInjuriesAccidents(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('accidents_addresses')
        .where('subcategory', isEqualTo: 'INJURIES') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamSlipandfallAccidents(
      String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('accidents_addresses')
        .where('subcategory', isEqualTo: 'Slip and Fall') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamChildbirthdelivery(
      String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('medical_addresses')
        .where('subcategory', isEqualTo: 'CHILDBIRTH') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamAnimalbites(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('medical_addresses')
        .where('subcategory', isEqualTo: 'ANIMAL BITES') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamDisaster(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('disaster_addresses')
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamEarthquake(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('disaster_addresses')
        .where('subcategory', isEqualTo: 'EARTHQUAKE') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamLandslide(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('disaster_addresses')
        .where('subcategory', isEqualTo: 'LANDSLIDE') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamFlood(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('disaster_addresses')
        .where('subcategory', isEqualTo: 'FLOOD') // Filter by category
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamEvacuation(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('evacuation_addresses')
        .snapshots();
  }

  static Stream<QuerySnapshot> getAddressStreamPolice(String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city) // Assuming `city` is the document ID
        .collection('police_addresses')
        .snapshots();
  }

  // stream adresses by id
  static Stream<DocumentSnapshot> getAddressStreamByIdFire(
      String id, String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('fire_addresses')
        .doc(id)
        .snapshots();
  }

  static Stream<DocumentSnapshot> getAddressStreamByIdAccidents(
      String id, String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('accidents_addresses')
        .doc(id)
        .snapshots();
  }

  static Stream<DocumentSnapshot> getAddressStreamByIdMedical(
      String id, String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('medical_addresses')
        .doc(id)
        .snapshots();
  }

  static Stream<DocumentSnapshot> getAddressStreamByIdDisaster(
      String id, String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('disaster_addresses')
        .doc(id)
        .snapshots();
  }

  static Stream<DocumentSnapshot> getAddressStreamByIdEvacuation(
      String id, String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('evacuation_addresses')
        .doc(id)
        .snapshots();
  }

  static Stream<DocumentSnapshot> getAddressStreamByIdPolice(
      String id, String? city) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('police_addresses')
        .doc(id)
        .snapshots();
  }

  // add addresses on each category
  static Future<void> addAddressFire(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('fire_addresses')
        .add(address);
  }

  static Future<void> addAddressAccidents(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('accidents_addresses')
        .add(address);
  }

  static Future<void> addAddressMedical(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('medical_addresses')
        .add(address);
  }

  static Future<void> addAddressDisaster(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('disaster_addresses')
        .add(address);
  }

  static Future<void> addAddressEvacuation(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('evacuation_addresses')
        .add(address);
  }

  static Future<void> addAddressPolice(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('police_addresses')
        .add(address);
  }

  // get addresses by id
  static Future<DocumentSnapshot> getAddressByIdFire(String city, String id) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('fire_addresses')
        .doc(id)
        .get();
  }

  static Future<DocumentSnapshot> getAddressByIdAccidents(
      String city, String id) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('accidents_addresses')
        .doc(id)
        .get();
  }

  static Future<DocumentSnapshot> getAddressByIdMedical(
      String city, String id) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('medical_addresses')
        .doc(id)
        .get();
  }

  static Future<DocumentSnapshot> getAddressByIdDisaster(
      String city, String id) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('disaster_addresses')
        .doc(id)
        .get();
  }

  static Future<DocumentSnapshot> getAddressByIdEvacuation(
      String city, String id) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('evacuation_addresses')
        .doc(id)
        .get();
  }

  static Future<DocumentSnapshot> getAddressByIdPolice(String city, String id) {
    return FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('police_addresses')
        .doc(id)
        .get();
  }

  // for update of each addresses
  static Future<void> updateAddressFire(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('fire_addresses')
        .doc(address['id'])
        .update(address);
  }

  static Future<void> updateAddressAccidents(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('accidents_addresses')
        .doc(address['id'])
        .update(address);
  }

  static Future<void> updateAddressMedical(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('medical_addresses')
        .doc(address['id'])
        .update(address);
  }

  static Future<void> updateAddressDisaster(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('disaster_addresses')
        .doc(address['id'])
        .update(address);
  }

  static Future<void> updateAddressEvacuation(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('evacuation_addresses')
        .doc(address['id'])
        .update(address);
  }

  static Future<void> updateAddressPolice(
      String selectedCity, Map<String, dynamic> address) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(selectedCity) // Assuming `city` is the document ID
        .collection('police_addresses')
        .doc(address['id'])
        .update(address);
  }

  // for deletion of addresses
  static Future<void> deleteAddressFire(String id, String city) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('fire_addresses')
        .doc(id)
        .delete();
  }

  static Future<void> deleteAddressAccidents(String id, String city) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('accidents_addresses')
        .doc(id)
        .delete();
  }

  static Future<void> deleteAddressMedical(String id, String city) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('medical_addresses')
        .doc(id)
        .delete();
  }

  static Future<void> deleteAddressDisaster(String id, String city) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('disaster_addresses')
        .doc(id)
        .delete();
  }

  static Future<void> deleteAddressEvacuation(String id, String city) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('evacuation_addresses')
        .doc(id)
        .delete();
  }

  static Future<void> deleteAddressPolice(String id, String city) async {
    await FirebaseFirestore.instance
        .collection('cities')
        .doc(city)
        .collection('police_addresses')
        .doc(id)
        .delete();
  }
}
