import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:kontak_application_2/pages/home_page.dart';

class PhoneNumberRegistrationPage extends StatefulWidget {
  const PhoneNumberRegistrationPage({super.key});

  @override
  State<PhoneNumberRegistrationPage> createState() =>
      _PhoneNumberRegistrationPageState();
}

class _PhoneNumberRegistrationPageState
    extends State<PhoneNumberRegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _verificationId;
  bool _canResend = false;
  bool _isLoading = false;

  String? _selectedCity;

  final List<String> _cities = [
    'Alfonso',
    'Amadeo',
    'Bacoor',
    'Carmona',
    'Cavite City',
    'Dasmariñas',
    'General Emilio Aguinaldo',
    'General Mariano Alvarez',
    'General Trias',
    'Imus',
    'Indang',
    'Kawit',
    'Magallanes',
    'Maragondon',
    'Mendez',
    'Naic',
    'Noveleta',
    'Rosario',
    'Silang',
    'Tagaytay',
    'Tanza',
    'Ternate',
    'Trece Martires'
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+63';
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
    });
    Future.delayed(const Duration(seconds: 30), () {
      setState(() {
        _canResend = true;
      });
    });
  }

  void _verifyPhoneNumber() async {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = _phoneController.text.replaceFirst('+63', '');

      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: '+63$phoneNumber',
          verificationCompleted: (PhoneAuthCredential credential) async {
            UserCredential userCredential =
                await _auth.signInWithCredential(credential);
            await _saveUserDetails(userCredential.user!.uid);
          },
          verificationFailed: (FirebaseAuthException e) {
            _handleVerificationError(e);
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
              _canResend = false;
            });
            _startResendTimer();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              _verificationId = verificationId;
            });
          },
        );
      } catch (e) {
        _showErrorDialog('An error occurred. Please try again.');
      }
    }
  }

  void _handleVerificationError(FirebaseAuthException e) {
    String message;
    if (e.code == 'invalid-phone-number') {
      message = 'The provided phone number is not valid.';
    } else if (e.code == 'phone-number-already-exists') {
      message = 'An account already exists for this phone number.';
    } else {
      message = e.message ?? 'An unknown error occurred.';
    }
    _showErrorDialog(message);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resendOtp() {
    _verifyPhoneNumber();
  }

  void _signInWithCode() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _codeController.text,
    );
    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    await _saveUserDetails(userCredential.user!.uid);
  }

  String blank = "";

  Future<void> _saveUserDetails(String uid) async {
    Map<String, dynamic> userInfoMap = {
      "uid": uid,
      "contact": _phoneController.text,
      "name": _nameController.text,
      "addressLine1": _addressLine1Controller.text,
      "addressLine2": _addressLine2Controller.text,
      "city": _selectedCity,
      "province": 'Cavite',
      "postalCode": _postalCodeController.text,
      "role": "User",
      "details": blank,
      "contactPersonAddress": blank,
      "contactPersonContact": blank,
      "contactPersonName": blank,
      "profilePictureUrl":
          "https://firebasestorage.googleapis.com/v0/b/kontak-application.appspot.com/o/profileImages%2Fno-profile-picture.png?alt=media&token=290b14bc-006a-4274-9ea9-8a869164d1a9",
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(userInfoMap);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  TextEditingController _dobController = TextEditingController();

  // Function to validate if the date field is empty
  String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your date of birth';
    }
    return null;
  }

  // Function to show the Date Picker and set the value
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Phone Number Registration')),
      backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  'assets/images/kontak_logo.png',
                  width: 300,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  'An Emergency and Hotline Assistance',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _phoneController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Phone Number (e.g., 9123456789)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 13,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _nameController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'First Name',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _nameController,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Last Name',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () =>
                        _selectDate(context), // Show date picker on tap
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dobController,
                        validator: validateDateOfBirth,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          hintText: 'Date of Birth',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _addressLine1Controller,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Address Line 1',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address line 1';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _addressLine2Controller,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Address Line 2',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    hint: const Text('Select City'),
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    initialValue: "Cavite", // Default value
                    readOnly: true, // Prevent modification
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Select Province', // Optional hint text
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _postalCodeController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Postal Code',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your postal code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
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
                    validator: (value) {
                      if (_verificationId != null &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter the verification code';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Space between buttons
                    children: [
                      // Resend OTP button
                      if (_canResend)
                        ElevatedButton(
                          onPressed: _resendOtp,
                          child: const Text('Resend OTP'),
                        ),
                      const SizedBox(width: 10),
                      // Verify button
                      _isLoading
                          ? const CircularProgressIndicator() // Loading indicator
                          : ElevatedButton(
                              onPressed: _verifyPhoneNumber,
                              child: const Text('Verify Phone Number'),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sign In button
                GestureDetector(
                  onTap: _verificationId != null ? _signInWithCode : null,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color:
                          _verificationId != null ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: _verificationId != null
                              ? Colors.white
                              : Colors.black38,
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
      ),
    );
  }
}
