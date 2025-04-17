import 'package:flutter/material.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_database.dart';
import 'package:kontak_application_2/pages/care_tips/caretips_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class DisasterEditCareTipPage extends StatefulWidget {
  final DisasterCareTip disasterCareTip;

  DisasterEditCareTipPage({required this.disasterCareTip});

  @override
  _DisasterEditCareTipPageState createState() =>
      _DisasterEditCareTipPageState();
}

class _DisasterEditCareTipPageState extends State<DisasterEditCareTipPage> {
  final DatabaseMethodsCareTips _databaseMethods = DatabaseMethodsCareTips();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _secondTitleController = TextEditingController();
  final TextEditingController _detailedInfoController = TextEditingController();
  late List<String> _images;
  String? _thumbnailUrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.disasterCareTip.title;
    _secondTitleController.text = widget.disasterCareTip.secondTitle;
    _detailedInfoController.text = widget.disasterCareTip.detailedInfo;
    _images = widget.disasterCareTip.images;
    _thumbnailUrl = widget.disasterCareTip.thumbnail;
  }

  Future<void> _pickThumbnail() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('care_tips/thumbnails/${Uuid().v4()}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _thumbnailUrl = downloadUrl;
      });
    }
  }

  void _removeThumbnail() {
    setState(() {
      _thumbnailUrl = null;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('care_tips/images/${Uuid().v4()}');
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _images.add(downloadUrl);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _editCareTip() async {
    if (_formKey.currentState!.validate()) {
      final updatedDisasterCareTip = DisasterCareTip(
        id: widget.disasterCareTip.id,
        title: _titleController.text,
        secondTitle: _secondTitleController.text,
        thumbnail: _thumbnailUrl!, // Allow null thumbnail
        images: _images,
        detailedInfo: _detailedInfoController.text,
      );
      await _databaseMethods.updateDisasterCareTip(updatedDisasterCareTip);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Care Tip'),
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
              ElevatedButton(
                onPressed: _pickThumbnail,
                child: Text(_thumbnailUrl == null
                    ? 'Add Thumbnail'
                    : 'Change Thumbnail'),
              ),
              if (_thumbnailUrl != null)
                Column(
                  children: [
                    Image.network(_thumbnailUrl!, height: 100, width: 100),
                    TextButton(
                      onPressed: _removeThumbnail,
                      child: Text('Remove Thumbnail'),
                    ),
                  ],
                ),
              SizedBox(height: 16),
              Text('Images:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _images.asMap().entries.map((entry) {
                  int index = entry.key;
                  String image = entry.value;
                  return Stack(
                    children: [
                      Image.network(image, height: 100, width: 100),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Icon(Icons.remove_circle, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Add Image'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _editCareTip,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
