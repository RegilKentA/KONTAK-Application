import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _checkEmailVerified();
  }

  Future<void> _checkEmailVerified() async {
    await _user?.reload();
    _user = _auth.currentUser;
    setState(() {
      _isVerified = _user?.emailVerified ?? false;
    });

    if (_isVerified) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } else {
      _showMessageDialog('Please check your email for verification.');
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      await _user?.sendEmailVerification();
      _showMessageDialog('Verification email sent. Please check your email.');
    } catch (e) {
      _showMessageDialog(
          'Failed to send verification email. Please try again later.');
    }
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
      ),
      body: Container(
        color: Color.fromRGBO(202, 230, 241, 1), // Set background color to blue
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A verification email has been sent to ${_user?.email}.',
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(
                  color: Colors
                      .black, // Change text color to white for better contrast
                ),
              ),
              const SizedBox(height: 16),
              if (!_isVerified)
                ElevatedButton(
                  onPressed: _checkEmailVerified,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set button color to green
                  ),
                  child: const Text(
                    'I have verified my email',
                    style: TextStyle(
                      color: Colors.white, // Change text color to yellow
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (!_isVerified)
                ElevatedButton(
                  onPressed: _resendVerificationEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set button color to green
                  ),
                  child: const Text(
                    'Resend Verification Email',
                    style: TextStyle(
                      color: Colors.white, // Change text color to yellow
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
