import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kontak_application_2/widgets/image_viewer.dart';

class PostDetailPage extends StatelessWidget {
  final DocumentSnapshot post;

  const PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(post['timestamp'].toDate());

    return Scaffold(
      backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
        title: Text(post['heading']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post['heading'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              post['details'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            if (post['imageUrls'] != null && post['imageUrls'].isNotEmpty)
              post['imageUrls'].length == 1
                  // If there's only one image, display it with a fixed height
                  ? Container(
                      width: double.infinity, // Make it cover the full width
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                imageUrls: List<String>.from(post['imageUrls']),
                                initialIndex:
                                    0, // Since there's only one image, start with index 0
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          post['imageUrls'][0],
                          fit: BoxFit
                              .cover, // Ensure the image covers the container
                        ),
                      ),
                    )
                  // If there are multiple images, display them in a grid
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: post['imageUrls'].length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two images per row
                        childAspectRatio: 1, // Aspect ratio of each grid item
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewer(
                                  imageUrls:
                                      List<String>.from(post['imageUrls']),
                                  initialIndex:
                                      index, // Index for the current image in the grid
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              height: 200.0, // Fixed height for each grid image
                              child: Image.network(
                                post['imageUrls'][index],
                                fit: BoxFit
                                    .cover, // Ensure the image covers the container
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            const SizedBox(height: 10),
            Text('Posted on: $formattedDate'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
