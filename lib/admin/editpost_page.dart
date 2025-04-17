import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontak_application_2/services/database.dart';

class EditPostPage extends StatefulWidget {
  final DocumentSnapshot post;

  const EditPostPage({required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final DatabaseMethods _databaseService = DatabaseMethods();
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  List<XFile>? _imageFiles;
  final ImagePicker _picker = ImagePicker();
  List<String> _networkImageUrls = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _headingController.text = widget.post['heading'];
    _detailsController.text = widget.post['details'];
    _networkImageUrls = List<String>.from(widget.post['imageUrls']);
  }

  void _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _imageFiles = pickedFiles;
    });
  }

  void _updatePost() async {
    if (_headingController.text.isEmpty || _detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<String> imageUrls = [];
    if (_imageFiles != null && _imageFiles!.isNotEmpty) {
      List<File> files = _imageFiles!.map((e) => File(e.path)).toList();
      imageUrls = await _databaseService.uploadImages(files);
    }
    imageUrls.addAll(_networkImageUrls);

    _databaseService
        .updatePost(
      widget.post.id,
      _headingController.text,
      _detailsController.text,
      imageUrls,
    )
        .then((_) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post updated successfully!')));
      Navigator.of(context).pop();
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error editing post! Please try again.')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text('Edit Post')),
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
                  _networkImageUrls.isNotEmpty
                      ? Column(
                          children: [
                            Wrap(
                              children: _networkImageUrls.map((url) {
                                return Stack(
                                  children: [
                                    Image.network(url, width: 100, height: 100),
                                    Positioned(
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _networkImageUrls.remove(url);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            Text(
                                '${_networkImageUrls.length} network image(s)'),
                          ],
                        )
                      : Container(),
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
                            Text(
                                '${_imageFiles!.length} local image(s) selected'),
                          ],
                        )
                      : Container(),
                  ElevatedButton(
                      onPressed: _pickImages, child: Text('Pick Images')),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _updatePost,
                    child: Text('Update Post'),
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
