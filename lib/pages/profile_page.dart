import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontak_application_2/pages/edit_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kontak_application_2/pages/reset_password_page.dart';
import 'package:kontak_application_2/services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:restart_app/restart_app.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      body: StreamBuilder<DocumentSnapshot>(
        stream: DatabaseMethods().getUserDetailsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No user data found"));
          }

          Map<String, dynamic>? userDetails =
              snapshot.data!.data() as Map<String, dynamic>?;

          String fullAddress = [
            userDetails?['addressLine1'] ?? '',
            userDetails?['addressLine2'] ?? '',
            userDetails?['city'] ?? '',
            userDetails?['province'] ?? '',
            userDetails?['postalCode'] ?? '',
          ].join(', ');

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacer(),

              CircleAvatar(
                radius: 80,
                backgroundImage:
                    NetworkImage(userDetails?['profilePictureUrl'] ?? ''),
              ),
              Spacer(),
              Text(
                userDetails?['name'] ?? 'User Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              Text(
                userDetails?['email'] ??
                    userDetails?['contact'] ??
                    'No Email or Phone',
                style: TextStyle(color: Colors.grey[600]),
              ),

              const SizedBox(height: 20), // Add some space

              // Centered "Edit Profile" button
              ElevatedButton(
                onPressed: () {
                  _showEditMenu(context);
                },
                child: Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.green,
                ),
              ),

              Spacer(),

              // Single Green Box Container with rounded corners
              Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.green[100], // Light green background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // My Details Section
                      Text("My Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      _buildDetailRow('Name', userDetails?['name']),
                      _buildDetailRow('Contact', userDetails?['contact']),
                      _buildDetailRow('Address', fullAddress),
                      _buildDetailRow('Details', userDetails?['details']),
                      const SizedBox(height: 30),

                      // Contact Person Section
                      Text('Contact Person',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      _buildDetailRow(
                          'Name', userDetails?['contactPersonName']),
                      _buildDetailRow(
                          'Address', userDetails?['contactPersonAddress']),
                      _buildDetailRow(
                          'Contact', userDetails?['contactPersonContact']),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditMenu(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              title: Text('Change Profile Picture'),
              onTap: () {
                Navigator.pop(context);
                _changeProfilePicture(context);
              },
            ),
            ListTile(
              title: Text('Edit Details'),
              onTap: () {
                Navigator.pop(context);
                // Pass user details to EditProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                        userId: FirebaseAuth.instance.currentUser!
                            .uid), // Pass actual user data here
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Delete Account'),
              onTap: () async {
                Navigator.pop(context);
                _confirmDeleteAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to confirm deletion of account
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
          title: const Text("Are you sure you want to delete your account?"),
          content: const Text(
              "This action cannot be undone, and your profile data will be lost."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount(context);
              },
              child: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to handle account deletion
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No user is logged in. Unable to delete account.')));
        return;
      }

      String userId = user.uid;

      // Step 1: Delete user data from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Step 2: Delete user's profile picture from Firebase Storage (if it exists)
      String? profilePictureUrl = user.photoURL;
      if (profilePictureUrl != null) {
        Reference profilePicRef =
            FirebaseStorage.instance.refFromURL(profilePictureUrl);
        await profilePicRef.delete();
      }

      // Step 3: Delete the user from Firebase Authentication (This invalidates the current session)
      await user.delete();
      print('User deleted');

      // Step 4: Log the user out
      FirebaseAuth.instance.signOut();
      print('User signed out');

      // restartApp(context);
      Restart.restartApp();

      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => const LoginPage()));
      print('User signed out');
    } catch (e) {
      // If something goes wrong, show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting account: $e'),
      ));
    }
  }

  // Function to handle profile picture change
  Future<void> _changeProfilePicture(BuildContext context) async {
    // Requesting permission to access photos
    PermissionStatus photosPermissionStatus = await Permission.photos.status;

    // Checking for photos permissions
    if (photosPermissionStatus.isGranted) {
      _pickImage(context);
    } else if (photosPermissionStatus.isDenied) {
      await Permission.photos.request();
    } else if (photosPermissionStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enable photos permission in the app settings.'),
          action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () async {
                openAppSettings();
              }),
        ),
      );
    }
  }

  // Function to pick image from gallery
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    // Pick image from gallery
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    try {
      // Upload the picked image to Firebase Storage
      File file = File(pickedImage.path);

      // Create a unique file name
      String fileName =
          'profile_pictures/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Get a reference to Firebase Storage
      Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);

      // Upload file to Firebase Storage
      await storageReference.putFile(file);

      // Get the download URL of the uploaded file
      String downloadUrl = await storageReference.getDownloadURL();

      // Update the Firestore document with the new profile picture URL
      await DatabaseMethods()
          .updateUserDetails({'profilePictureUrl': downloadUrl});

      // Update the Firebase Authentication profile photo URL
      await FirebaseAuth.instance.currentUser!.updateProfile(
        photoURL: downloadUrl, // Update photoURL in Firebase Authentication
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      print("Error updating profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error updating profile picture. Please try again later.')),
      );
    }
  }

  Widget _buildDetailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          Flexible(
            child: Text(
              value ?? 'N/A',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
