import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_database.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_model.dart';
import 'package:uuid/uuid.dart';

class FirstAidAddCareTipPage extends StatefulWidget {
  @override
  _FirstAidAddCareTipPageState createState() => _FirstAidAddCareTipPageState();
}

class _FirstAidAddCareTipPageState extends State<FirstAidAddCareTipPage> {
  final DatabaseMethodsCareTips _databaseMethods = DatabaseMethodsCareTips();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _secondTitleController = TextEditingController();
  final TextEditingController _detailedInfoController = TextEditingController();
  final List<String> _images = [];
  String? _thumbnail;
  String? _subcategory;
  final _formKey = GlobalKey<FormState>();

  // list of subcategory
  List<String> _subcategories = [
    'Burns',
    'Fracture',
    'Poisoning',
    'Bites',
    'Stroke',
    'Heat Stroke',
    'Heart Attack',
    'Wounds',
    'Bandaging',
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('care_tips/${Uuid().v4()}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _images.add(downloadUrl);
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('care_tips_thumbnails/${Uuid().v4()}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _thumbnail = downloadUrl;
      });
    }
  }

  void _addCareTip() async {
    if (_formKey.currentState!.validate() && _thumbnail != null) {
      final careTip = CareTip(
        id: Uuid().v4(),
        title: _titleController.text,
        secondTitle: _secondTitleController.text,
        images: _images,
        detailedInfo: _detailedInfoController.text,
        thumbnail: _thumbnail!, // Ensure the thumbnail is included
        subcategory: _subcategory!,
      );
      await _databaseMethods.addCareTip(careTip);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Care Tip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _secondTitleController,
                decoration: InputDecoration(labelText: 'Second Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a second title' : null,
              ),
              TextFormField(
                controller: _detailedInfoController,
                decoration: InputDecoration(labelText: 'Detailed Info'),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter detailed information' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _subcategory,
                decoration: InputDecoration(labelText: 'Select Subcategory'),
                items: _subcategories.map((String subcategory) {
                  return DropdownMenuItem<String>(
                    value: subcategory,
                    child: Text(subcategory),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _subcategory = newValue;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Add Image'),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _images
                    .map((image) =>
                        Image.network(image, height: 100, width: 100))
                    .toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickThumbnail,
                child: Text('Add Thumbnail'),
              ),
              if (_thumbnail != null)
                Image.network(_thumbnail!, height: 100, width: 100),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addCareTip,
                child: Text('Add Care Tip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
