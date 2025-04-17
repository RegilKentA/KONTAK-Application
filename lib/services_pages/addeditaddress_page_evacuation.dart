import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kontak_application_2/services_pages/address_database.dart';
import 'package:permission_handler/permission_handler.dart';

class AddEditAddressPageEvacuation extends StatefulWidget {
  final String? addressId;
  final String? selectedCity;

  AddEditAddressPageEvacuation({
    this.addressId,
    this.selectedCity,
  });

  @override
  _AddEditAddressPageEvacuationState createState() =>
      _AddEditAddressPageEvacuationState();
}

class _AddEditAddressPageEvacuationState
    extends State<AddEditAddressPageEvacuation> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _cellphoneController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _addressline1Controller = TextEditingController();
  final TextEditingController _addressline2Controller = TextEditingController();
  final TextEditingController _postalcodeController = TextEditingController();

  File? _thumbnail;
  final ImagePicker _picker = ImagePicker();

  // Dropdown variables
  String? _selectedCity;
  String? _thumbnailUrl;
  bool _isLoading = false;
  bool _isPermissionGranted = false;
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
    if (widget.addressId != null) {
      _loadAddress();
    }
  }

  Future<void> _loadAddress() async {
    var doc = await Database.getAddressByIdEvacuation(
        widget.selectedCity!, widget.addressId!);

    // Check if the document exists
    if (doc.exists) {
      var address = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = address['name'] ?? '';
        _telephoneController.text = address['telephone'] ?? '';
        _cellphoneController.text = address['cellphone'] ?? '';
        _latitudeController.text = address['latitude'].toString();
        _longitudeController.text = address['longitude'].toString();
        _addressline1Controller.text = address['addressLine1'] ?? '';
        _addressline2Controller.text = address['addressLine2'] ?? '';
        _selectedCity = address['city'] ?? '';
        _postalcodeController.text = address['postalCode'] ?? '';
        _thumbnailUrl = address['thumbnail'];
      });
    } else {
      // Handle the case where the address doesn't exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address not found.')),
      );
    }
  }

  Future<void> _checkPermissions() async {
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted) {
      // If the permission is granted
      setState(() {
        _isPermissionGranted = true;
      });
    } else if (status.isDenied) {
      // If the permission is denied, request it
      PermissionStatus newStatus = await Permission.photos.request();

      setState(() {
        _isPermissionGranted = newStatus.isGranted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Permission denied. Please allow access to your photos.')),
      );
    } else if (status.isPermanentlyDenied) {
      // If the permission is permanently denied, guide the user to settings
      setState(() {
        _isPermissionGranted = false;
      });
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

  Future<void> _pickThumbnail() async {
    await _checkPermissions();
    if (_isPermissionGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _thumbnail = File(pickedFile.path);
        });
      }
    }
  }

  Future<String> _uploadThumbnail(File image) async {
    // Create a reference to the Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();
    // Create a unique file name
    String fileName = 'thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg';
    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageRef.child(fileName).putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(202, 230, 241, 1),
        title: Text(widget.addressId == null ? 'Add Address' : 'Edit Address'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Address Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an address name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _telephoneController,
                      decoration: InputDecoration(
                          labelText: 'Telephone Number (optional)'),
                    ),
                    TextFormField(
                      controller: _cellphoneController,
                      decoration: InputDecoration(
                          labelText: 'Cellphone Number (optional)'),
                    ),
                    TextFormField(
                      controller: _latitudeController,
                      decoration: InputDecoration(labelText: 'Latitude'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a latitude';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid latitude';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _longitudeController,
                      decoration: InputDecoration(labelText: 'Longitude'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a longitude';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid longitude';
                        }
                        return null;
                      },
                    ),
                    // Address Line 1 Field
                    TextFormField(
                      controller: _addressline1Controller,
                      decoration: InputDecoration(labelText: 'Adress Line 1'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Address Line 1';
                        }
                        return null;
                      },
                    ),
                    // Address Line 2 Field
                    TextFormField(
                      controller: _addressline2Controller,
                      decoration: InputDecoration(labelText: 'Adress Line 2'),
                    ),

                    SizedBox(height: 20),
                    // City Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      hint: const Text('Select City'),
                      isExpanded: true,
                      items: _cities.map((String city) {
                        return DropdownMenuItem<String>(
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

                    // Cavite Field
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(labelText: 'Cavite'),
                    ),

                    // Postal Code Field
                    TextFormField(
                      controller: _postalcodeController,
                      decoration: InputDecoration(labelText: 'Postal Code'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Postal Code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Thumbnail Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thumbnail'),
                        ElevatedButton(
                          onPressed: _pickThumbnail,
                          child: Text('Pick Image'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _thumbnail != null
                        ? Column(
                            children: [
                              Image.file(
                                _thumbnail!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _thumbnail = null;
                                  });
                                },
                                child: Text('Remove Thumbnail'),
                              ),
                            ],
                          )
                        : _thumbnailUrl != null
                            ? Column(
                                children: [
                                  Image.network(
                                    _thumbnailUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _thumbnailUrl = null;
                                      });
                                    },
                                    child: Text('Remove Thumbnail'),
                                  ),
                                ],
                              )
                            : Container(
                                height: 100,
                                color: Colors.grey[200],
                                child: Center(
                                    child: Text('No Thumbnail Selected')),
                              ),
                    SizedBox(height: 20),
                    //Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                if (_formKey.currentState!.validate()) {
                                  // Check if thumbnail is not null
                                  String? thumbnailUrl;
                                  if (_thumbnail != null) {
                                    // Upload the thumbnail and get the URL if a new image is picked
                                    thumbnailUrl =
                                        await _uploadThumbnail(_thumbnail!);
                                  } else if (_thumbnailUrl != null) {
                                    // Use existing thumbnail URL if no new image is picked
                                    thumbnailUrl = _thumbnailUrl;
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Please select a thumbnail')),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    return;
                                  }

                                  var addressData = {
                                    'name': _nameController.text,
                                    'telephone':
                                        _telephoneController.text.isNotEmpty
                                            ? _telephoneController.text
                                            : null,
                                    'cellphone':
                                        _cellphoneController.text.isNotEmpty
                                            ? _cellphoneController.text
                                            : null,
                                    'latitude':
                                        double.parse(_latitudeController.text),
                                    'longitude':
                                        double.parse(_longitudeController.text),
                                    'addressLine1':
                                        _addressline1Controller.text,
                                    'addressLine2':
                                        _addressline2Controller.text,
                                    'city': _selectedCity,
                                    'province': 'Cavite',
                                    'postalCode': _postalcodeController.text,
                                    'thumbnail': thumbnailUrl,
                                    'stationType': 'Evacuation',
                                  };
                                  if (widget.addressId == null) {
                                    await Database.addAddressEvacuation(
                                        widget.selectedCity!, addressData);
                                  } else {
                                    addressData['id'] = widget.addressId!;
                                    await Database.updateAddressEvacuation(
                                        widget.selectedCity!, addressData);
                                  }
                                  Navigator.pop(context);
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
