import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/pages/emailverification_page.dart';
import 'package:kontak_application_2/pages/home_page.dart';
import 'package:kontak_application_2/pages/login_page.dart';

class AuthService extends StatelessWidget {
  const AuthService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('An error occurred. Please try again later.'));
          } else if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user != null) {
              // Check if the user registered via phone number
              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
                // User signed up with phone number, log them in directly
                return const HomePage();
              }

              // If user is logged in with email and not verified
              if (user.email != null && !user.emailVerified) {
                return const EmailVerificationPage();
              }

              // User is logged in and verified
              return const HomePage();
            }
          } else {
            return const LoginPage();
          }
          // User is not logged in
          return const LoginPage();
        },
      ),
    );
  }
}
