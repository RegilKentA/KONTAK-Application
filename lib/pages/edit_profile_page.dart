import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kontak_application_2/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController detailsController;
  late TextEditingController contactController;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController provinceController;
  late TextEditingController postalCodeController;
  late TextEditingController contactPersonNameController;
  late TextEditingController contactPersonAddressController;
  late TextEditingController contactPersonContactController;

  String? selectedCity;
  bool _isCityLoaded = false;

  List<String> cityList = [
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
    // Initialize controllers
    nameController = TextEditingController();
    detailsController = TextEditingController();
    contactController = TextEditingController();
    addressLine1Controller = TextEditingController();
    addressLine2Controller = TextEditingController();
    provinceController = TextEditingController();
    postalCodeController = TextEditingController();
    contactPersonNameController = TextEditingController();
    contactPersonAddressController = TextEditingController();
    contactPersonContactController = TextEditingController();
  }

  Future<void> _saveUserData() async {
    try {
      await DatabaseMethods().updateUserDetails({
        'name': nameController.text,
        'details': detailsController.text,
        'contact': contactController.text,
        'addressLine1': addressLine1Controller.text,
        'addressLine2': addressLine2Controller.text,
        'city': selectedCity ?? 'Select City',
        'province': provinceController.text,
        'postalCode': postalCodeController.text,
        'contactPersonName': contactPersonNameController.text,
        'contactPersonAddress': contactPersonAddressController.text,
        'contactPersonContact': contactPersonContactController.text,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context); // Close the edit page
    } catch (e) {
      print("Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error updating profile. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Edit Profile"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No user data found"));
          }

          Map<String, dynamic> userDetails =
              snapshot.data!.data() as Map<String, dynamic>;

          // Initialize controllers with the fetched user details
          nameController.text = userDetails['name'];
          detailsController.text = userDetails['details'] ?? '';
          contactController.text = userDetails['contact'] ?? '';
          addressLine1Controller.text = userDetails['addressLine1'] ?? '';
          addressLine2Controller.text = userDetails['addressLine2'] ?? '';
          provinceController.text = userDetails['province'];
          postalCodeController.text = userDetails['postalCode'] ?? '';
          contactPersonNameController.text =
              userDetails['contactPersonName'] ?? '';
          contactPersonAddressController.text =
              userDetails['contactPersonAddress'] ?? '';
          contactPersonContactController.text =
              userDetails['contactPersonContact'] ?? '';
          if (!_isCityLoaded) {
            selectedCity = userDetails['city'];
            _isCityLoaded = true;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                _buildTextFieldFixed("Name", nameController),
                _buildTextFieldContactNum("Contact", contactController),
                _buildTextField("Address Line 1", addressLine1Controller),
                _buildTextField("Address Line 2", addressLine2Controller),
                _buildDropdownField("City", cityList, selectedCity, (newCity) {
                  setState(() {
                    selectedCity = newCity;
                  });
                }),
                _buildTextFieldFixed("Province", provinceController),
                _buildTextFieldPostalCode("Postal Code", postalCodeController),
                _buildTextField("Details", detailsController),
                const SizedBox(height: 20),
                _buildTextField(
                    "Contact Person Name", contactPersonNameController),
                _buildTextField(
                    "Contact Person Address", contactPersonAddressController),
                _buildTextFieldContactNum(
                    "Contact Person Contact", contactPersonContactController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveUserData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildTextFieldPostalCode(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
      ),
    );
  }

  Widget _buildTextFieldContactNum(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13),
        ],
      ),
    );
  }

  Widget _buildTextFieldFixed(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newCity) {
          if (newCity != null) {
            onChanged(newCity);
          }
        },
      ),
    );
  }
}
