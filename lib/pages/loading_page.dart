import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromRGBO(202, 230, 241, 1), // Background color
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo at the top center
              Padding(
                padding:
                    const EdgeInsets.only(top: 100.0), // Padding from the top
                child: Center(
                  child: Image.asset(
                    'assets/images/loading_logo.png', // Replace with your logo image path
                    height: 400, // Set the height of the logo
                  ),
                ),
              ),
              // Partners logo at the bottom center
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 50.0), // Padding from the bottom
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'PARTNERED BY:',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Image.asset(
                        'assets/images/PDRRMO.png', // Replace with your partners logo image path
                        height: 170, // Set the height of the partners logo
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
