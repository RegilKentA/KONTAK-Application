import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_application_2/services/database.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final DatabaseMethods _databaseService = DatabaseMethods();
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  List<XFile>? _imageFiles;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  void _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _imageFiles = pickedFiles;
    });
  }

  void _uploadPost() async {
    if (_headingController.text.isEmpty ||
        _detailsController.text.isEmpty ||
        _imageFiles == null ||
        _imageFiles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all fields and pick images.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<File> files = _imageFiles!.map((e) => File(e.path)).toList();
    List<String> imageUrls = await _databaseService.uploadImages(files);
    _databaseService
        .addPost(_headingController.text, _detailsController.text, imageUrls)
        .then((_) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post added successfully!')));
      _headingController.clear();
      _detailsController.clear();
      setState(() {
        _imageFiles = null;
      });
      Navigator.of(context).pop();
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding post! Please try again.')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text('Add Post')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _headingController,
                    decoration: InputDecoration(labelText: 'Heading'),
                  ),
                  TextField(
                    controller: _detailsController,
                    decoration: InputDecoration(labelText: 'Details'),
                    maxLines: 5,
                  ),
                  SizedBox(height: 10),
                  _imageFiles != null && _imageFiles!.isNotEmpty
                      ? Column(
                          children: [
                            Wrap(
                              children: _imageFiles!.map((image) {
                                return Stack(
                                  children: [
                                    Image.file(File(image.path),
                                        width: 100, height: 100),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _imageFiles!.remove(image);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            Text('${_imageFiles!.length} image(s) selected'),
                          ],
                        )
                      : Text('No images selected.'),
                  ElevatedButton(
                      onPressed: _pickImages, child: const Text('Pick Images')),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _uploadPost,
                    child: const Text('Add Post'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
