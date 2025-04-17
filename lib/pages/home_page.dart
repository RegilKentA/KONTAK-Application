import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/admin/adduser_page.dart';
import 'package:kontak_application_2/admin/analytics_page.dart';
import 'package:kontak_application_2/pages/aboutus_page.dart';
import 'package:kontak_application_2/pages/apptutorial_page.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_category_page.dart';
import 'package:kontak_application_2/pages/categoryservices_page.dart';
import 'package:kontak_application_2/emergencycall_button/emergencybutton_page.dart';
import 'package:kontak_application_2/pages/login_page.dart';
import 'package:kontak_application_2/pages/news_page.dart';
import 'package:kontak_application_2/pages/privacy_policy_page.dart';
import 'package:kontak_application_2/pages/profile_page.dart';
import 'package:kontak_application_2/responders/reponders_dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  // String? userRole = '';
  // String? userEmail = '';
  String? userRole;
  String? userStationID;
  String? adminMunicipality;
  String? userEmail;
  String? userPnumber;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // List of screens to display
  final List<Widget> screens = [
    const CategoryServices(),
    CareTipsCategoryPage(),
    NewsPage(),
    const ProfilePage(),
  ];

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot? userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          // Safe access to the fields
          var data = userDoc.data() as Map<String, dynamic>?;

          // Accessing fields safely with a fallback if they don't exist
          userRole = data?['role'] as String?;
          userStationID = data?['userStationID'] as String?;
          adminMunicipality = data?['adminMunicipality'] as String?;
          // userPnumber = data?['contact'] as String?;

          // Safely access the 'email' or 'contact' field with a fallback
          userEmail = data?['email'] ?? data?['contact'] ?? 'No Email or Phone';
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar designs
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/images/kontak_logo.png',
                width: 120,
                height: 54,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          Builder(builder: (context) {
            // right menu drawer icon
            return IconButton(
              icon: const Icon(
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
        backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                'assets/images/kontak_logo.png',
                width: 300,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                '$userRole: $userEmail',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            if (userRole == 'Responder') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Station: $userStationID',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
            if (userRole == 'Sub-Admin') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'Municipality: $adminMunicipality',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            Divider(
              thickness: 0.5,
              color: Colors.grey[600],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
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
                    title: const Text('Privacy Policy'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyAndPolicy()),
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
                  if (userRole == 'Admin') // Conditional rendering
                    ListTile(
                      title: const Text('Add User'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddUserPage()),
                        );
                      },
                    ),
                  if (userRole == 'Admin') // Conditional rendering
                    ListTile(
                      title: const Text('Report Analytics'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnalyticsPage()),
                        );
                      },
                    ),
                  if (userRole == 'Responder') // Conditional rendering
                    ListTile(
                      title: const Text("Responder's Dashboard"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RespondersDashboardPage()),
                        );
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: signUserOut,
                ),
              ),
            ),
          ],
        ),
      ),

      // emergency call button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmergencybuttonPage()),
            );
          },
          backgroundColor: Colors.green,
          shape: const CircleBorder(),
          child: Image.asset(
            'assets/images/kontak_loc_logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),

      // navigation bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
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
              const SizedBox(width: 40),
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
