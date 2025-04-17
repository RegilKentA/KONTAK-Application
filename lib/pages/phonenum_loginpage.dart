import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kontak_application_2/pages/home_page.dart';

class PhoneNumberLoginPage extends StatefulWidget {
  const PhoneNumberLoginPage({super.key});

  @override
  _PhoneNumberLoginPageState createState() => _PhoneNumberLoginPageState();
}

class _PhoneNumberLoginPageState extends State<PhoneNumberLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+63';
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
    });
    Future.delayed(Duration(seconds: 30), () {
      setState(() {
        _canResend = true;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Add phone number validation logic (e.g., regex)
    return phoneNumber.length >= 10; // Adjust based on your requirements
  }

  void _verifyPhoneNumber() async {
    if (!_isValidPhoneNumber(_phoneController.text)) {
      _showErrorDialog('Please enter a valid phone number.');
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => HomePage()), // Navigate to home page
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          _showErrorDialog(e.message ?? 'Verification failed');
          setState(() {
            _isLoading = false; // Stop loading
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false; // Stop loading
          });
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false; // Stop loading
          });
          _showErrorDialog(
              'Verification code timed out. Please request a new code.');
        },
      );
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  void _signInWithCode() async {
    if (_codeController.text.isEmpty) {
      _showErrorDialog('Please enter the verification code.');
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );
      await _auth.signInWithCredential(credential);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => HomePage()), // Navigate to home page
      );
    } catch (e) {
      _showErrorDialog('Invalid verification code. Please try again.');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
    }
  }

  void _resendVerificationCode() {
    _verifyPhoneNumber(); // Resend the verification code
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
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
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: Text('Phone Number Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                'assets/images/kontak_logo.png',
                width: 300,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 80),
              Text(
                'An Emergency and Hotline Assistance',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _phoneController,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    hintText: 'Phone Number (e.g., 9123456789)',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength:
                      13, // Adjust the length based on the country code and number
                  enabled: !_isLoading, // Disable during loading
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    hintText: 'Verification Code',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: _verificationId != null &&
                      !_isLoading, // Disable during loading
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Space between buttons
                  children: [
                    // Resend OTP button
                    if (_canResend)
                      ElevatedButton(
                        onPressed: _resendVerificationCode,
                        child: Text('Resend OTP'),
                      ),
                    const SizedBox(width: 10),
                    // Verify button
                    _isLoading
                        ? CircularProgressIndicator() // Loading indicator
                        : ElevatedButton(
                            onPressed: _verifyPhoneNumber,
                            child: Text('Verify Phone Number'),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sign In button
              GestureDetector(
                onTap: _verificationId != null && !_isLoading
                    ? _signInWithCode
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: _verificationId != null && !_isLoading
                        ? Colors.blue
                        : Colors.grey, // Change color based on enabled state
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: _verificationId != null && !_isLoading
                            ? Colors.white
                            : Colors
                                .black38, // Change text color based on enabled state
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
