import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kontak_application_2/admin/addpost_page.dart';
import 'package:kontak_application_2/admin/editpost_page.dart';
import 'package:kontak_application_2/services/database.dart';
import 'package:kontak_application_2/widgets/post_card.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final DatabaseMethods _databaseService = DatabaseMethods();

  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch the user's document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Check if the user document exists and if the role is 'admin'
      if (userDoc.exists && userDoc['role'] == 'Admin') {
        setState(() {
          isAdmin = true;
        });
      }
    }
  }

  void _showAddPostPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddPostPage()),
    );
  }

  void _showEditPostPage(DocumentSnapshot post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPostPage(post: post),
      ),
    );
  }

  void _deletePost(String postId) {
    _databaseService.deletePost(postId).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      appBar: AppBar(
        title: const Text(
          'News Page',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Color.fromARGB(255, 116, 116, 116),
                blurRadius: 2.0,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromRGBO(202, 230, 241, 1),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('news')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data?.docs[index];
              return PostCard(
                post: post!,
                onEdit: () => _showEditPostPage(post),
                onDelete: () => _deletePost(post.id),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                _showAddPostPage();
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}
