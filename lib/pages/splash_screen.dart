import 'package:flutter/material.dart';
import 'package:kontak_application_2/pages/termscondition_page.dart';
import 'package:kontak_application_2/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTermsAccepted();
  }

  Future<void> _checkTermsAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool termsAccepted = prefs.getBool('terms_accepted') ?? false;

    if (termsAccepted) {
      // Navigate to authentication or login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AuthService()), // Ensure this is a valid widget
      );
    } else {
      // Navigate to Terms and Conditions page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
