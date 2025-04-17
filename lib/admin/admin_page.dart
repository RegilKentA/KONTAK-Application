import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/pages/aboutus_page.dart';
import 'package:kontak_application_2/pages/apptutorial_page.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_category_page.dart';
import 'package:kontak_application_2/pages/categoryservices_page.dart';
import 'package:kontak_application_2/emergencycall_button/emergencybutton_page.dart';
import 'package:kontak_application_2/pages/login_page.dart';
import 'package:kontak_application_2/pages/news_page.dart';
import 'package:kontak_application_2/pages/profile_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int index = 0;
  String? userEmail;
  void initState() {
    super.initState();

    // Get the currently logged-in user and fetch the email
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email; // Fetch the email
    }
  }

  // List of screens to display
  final List<Widget> screens = [
    CategoryServices(),
    CareTipsCategoryPage(),
    NewsPage(),
    ProfilePage(),
  ];

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar designs
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0), // Adjust padding as needed
              child: Image.asset(
                'assets/images/kontak_logo.png',
                width: 120, // Set the width you want
                height: 54, // Set the height you want
                fit: BoxFit.contain, // Adjust BoxFit as needed
              ),
            ),
            SizedBox(
                width: 8), // Adjust spacing between image and title as needed
            // Text('App Bar with Image'),
          ],
        ),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                size: 40,
                color: Color(0xff18A54A),
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            );
          }),
        ],
      ),

      // right menu drawer
      endDrawer: Drawer(
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/kontak_logo.png',
                width: 300, // Set the width you want
                height: 150, // Set the height you want
                fit: BoxFit.contain, // Adjust BoxFit as needed
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Admin: $userEmail',
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: const Text('App Tutorial'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TutorialPage()),
                );
              },
            ),
            ListTile(
              title: const Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: signUserOut,
            ),
          ],
        ),
      ),

      // emergency call button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 80, // Set the desired width
        height: 80, // Set the desired height
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmergencybuttonPage()),
            );
          },
          backgroundColor: Colors.green,
          shape: CircleBorder(),
          child: Image.asset(
            'assets/images/kontak_loc_logo.png',
            width: 120, // Set the width you want
            height: 120, // Set the height you want
            fit: BoxFit.contain, // Adjust BoxFit as needed
          ), // Adjust icon size if needed
        ),
      ),

      // navigation bar
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    index = 0;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      size: 30,
                      color: index == 0 ? Colors.green : Colors.grey,
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        color: index == 0 ? Colors.green : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index = 1;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_hospital,
                      size: 30,
                      color: index == 1 ? Colors.green : Colors.grey,
                    ),
                    Text(
                      'Care',
                      style: TextStyle(
                        color: index == 1 ? Colors.green : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 40),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index = 2;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.article,
                      size: 30,
                      color: index == 2 ? Colors.green : Colors.grey,
                    ),
                    Text(
                      'News',
                      style: TextStyle(
                        color: index == 2 ? Colors.green : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    index = 3;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      size: 30,
                      color: index == 3 ? Colors.green : Colors.grey,
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: index == 3 ? Colors.green : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Body to display the selected screen
      body: screens[index],
    );
  }
}
