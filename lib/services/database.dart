import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Adding user details
  Future<void> addUserDetails(
      Map<String, dynamic> userInfoMap, String uid) async {
    await _db.collection("users").doc(uid).set(userInfoMap);
  }

  // Getting user data
  Stream<DocumentSnapshot> getUserDetailsStream() {
    if (currentUser != null) {
      return _db.collection("users").doc(currentUser!.uid).snapshots();
    } else {
      throw Exception("No user logged in");
    }
  }

  // Updating user profile details
  Future<void> updateUserDetails(Map<String, String> map) async {
    await _db.collection("users").doc(currentUser!.uid).update(map);
  }

  // Updating user profile picture
  Future<void> updateUserData(String uid, String profileImageUrl) async {
    await _db.collection('users').doc(uid).update({
      'profilePictureUrl': profileImageUrl,
    });
  }

  // Uploading pictures for a new post
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> imageUrls = [];
    for (var file in imageFiles) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          _storage.ref().child('news_images/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }
    return imageUrls;
  }

  // Adding post details to the database
  Future<void> addPost(
      String heading, String details, List<String> imageUrls) async {
    await _db.collection('news').add({
      'heading': heading,
      'details': details,
      'imageUrls': imageUrls,
      'timestamp': Timestamp.now(),
    });
  }

  // Modifying/updating post
  Future<void> updatePost(String postId, String heading, String details,
      List<String> imageUrls) async {
    await _db.collection('news').doc(postId).update({
      'heading': heading,
      'details': details,
      'imageUrls': imageUrls,
      'timestamp': Timestamp.now(),
    });
  }

  // Deleting the post
  Future<void> deletePost(String postId) async {
    await _db.collection('news').doc(postId).delete();
  }

  //ref number and details data saving
  static Future<void> saveEmergencyIncident(
      String referenceNumber,
      String userId,
      String name,
      String address,
      String email,
      String contact,
      String emergencyNumber) async {
    // Get a reference to your Firestore collection
    CollectionReference incidents =
        FirebaseFirestore.instance.collection('emergency_incident');

    // Save the incident data
    await incidents.add({
      'referenceNumber': referenceNumber,
      'userId': userId,
      'name': name,
      'address': address,
      'email': email,
      'contact': contact,
      'emergencyNumber': emergencyNumber,
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
    });
  }
}
