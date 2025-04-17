import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/custom_backbutton_white.dart';

class TutorialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButtonWhite(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'App Tutorial',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome to the App Tutorial!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Image.asset('assets/images/One.png'),
                SizedBox(height: 5.0), // Space between images
                Image.asset('assets/images/Two.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Three.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Four.png'),
                SizedBox(height: 5.0), // Space between images
                Image.asset('assets/images/Five.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Six.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Seven.png'),
                SizedBox(height: 5.0), // Space between images
                Image.asset('assets/images/Eight.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Nine.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Ten.png'),
                SizedBox(height: 5.0), // Space between images
                Image.asset('assets/images/Eleven.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Twelve.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Thirteen.png'),
                SizedBox(height: 5.0), // Space between images
                Image.asset('assets/images/Fourteen.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Fifteen.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Sixteen.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Seventeen.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Eighteen.png'),
                SizedBox(height: 5.0),
                Image.asset('assets/images/Nineteen.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
