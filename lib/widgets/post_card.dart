import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:kontak_application_2/pages/postdetail_page.dart';

class PostCard extends StatefulWidget {
  final DocumentSnapshot post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostCard(
      {required this.post, required this.onEdit, required this.onDelete});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'];
        });
      }
    }
  }

  void _navigateToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: widget.post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
// Format the timestamp to include date and time up to minutes
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm')
        .format(widget.post['timestamp'].toDate());

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.post['heading'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow
                          .ellipsis, // Ensure the text doesn't overflow
                      maxLines: 2, // Limit to a single line
                    ),
                  ),
                  if (userRole == 'Admin')
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit();
                        } else if (value == 'delete') {
                          widget.onDelete();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Edit', 'Delete'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice.toLowerCase(),
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                ],
              ),
              Text('Posted on: $formattedDate'),
              SizedBox(height: 10),
              Text(
                widget.post['details'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              // Image display logic: Check if there's only one image
              if (widget.post['imageUrls'] != null &&
                  widget.post['imageUrls'].isNotEmpty)
                // If there's only one image, display it taking up full width
                widget.post['imageUrls'].length == 1
                    ? Container(
                        width: double
                            .infinity, // Make sure it covers the full width
                        height: 200.0,
                        child: Image.network(
                          widget.post['imageUrls'][0],
                          fit: BoxFit.cover,
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: widget.post['imageUrls'].length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Display two images per row
                          childAspectRatio: 1, // Aspect ratio of each grid item
                        ),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Image.network(
                              widget.post['imageUrls'][index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
              SizedBox(
                height: 5,
              )
            ],
          ),
        ),
      ),
    );
  }
}
