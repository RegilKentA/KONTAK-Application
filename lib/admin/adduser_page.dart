import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:kontak_application_2/components/custom_backbutton.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCity;
  String? _selectedRole;
  String? _selectedMunicipality;
  bool _obscureText = true;

  final List<String> cities = [
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
  final List<String> roles = ['Admin', 'Sub-Admin', 'Responder'];
  final List<String> municipalities = [
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _userStationIdController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    _userStationIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your contact number';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid contact number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create a new user with Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Send verification email
        await userCredential.user?.sendEmailVerification();

        // Add user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text,
          'email': _emailController.text,
          'contact': _contactController.text,
          'addressLine1': _addressLine1Controller.text,
          'addressLine2': _addressLine2Controller.text,
          'city': _selectedCity,
          'province': 'Cavite',
          'postalCode': _postalCodeController.text,
          'userStationID': _userStationIdController.text.isNotEmpty
              ? _userStationIdController.text
              : null, // Optional
          'role': _selectedRole,
          'adminMunicipality': _selectedMunicipality, // Optional
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'User added successfully! A verification email has been sent.')),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        leading: CustomBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Add User',
          style: TextStyle(color: Colors.green),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    fillColor: Colors.grey.shade200,
                    filled: true,
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Toggle the icon based on the _obscureText value
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          // Toggle the visibility of the password
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Contact',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  keyboardType: TextInputType.phone,
                  validator: _validateContact,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Address Line 1',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address line 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Address Line 2',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'City',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  items: cities.map((city) {
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
                  validator: (value) =>
                      value == null ? 'Please select a city' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
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
                const SizedBox(height: 10),
                TextFormField(
                  controller: _postalCodeController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Postal Code',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your postal code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Role',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a role' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedMunicipality,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Sub-Admin Municipality',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  items: municipalities.map((municipality) {
                    return DropdownMenuItem(
                      value: municipality,
                      child: Text(municipality),
                    );
                  }).toList(),
                  onChanged:
                      (_selectedRole == 'Admin' || _selectedRole == 'Responder')
                          ? null
                          : (value) {
                              setState(() {
                                _selectedMunicipality = value;
                              });
                            },
                  // No validator for this field, making it optional
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _userStationIdController,
                  enabled:
                      _selectedRole != 'Admin' && _selectedRole != 'Sub-Admin',
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Responder Exact/Full Station Name',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add User'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Colors.green), // Set the background color
                    foregroundColor: MaterialStateProperty.all(
                        Colors.white), // Set the text color
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15)), // Optional padding
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
