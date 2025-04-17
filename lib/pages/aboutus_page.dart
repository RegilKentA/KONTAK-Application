// about_us_page.dart
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/custom_backbutton_white.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: CustomBackButtonWhite(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'About Us',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('About Us'),
            _buildSectionContent(
                'Welcome to KONTAK, the emergency and hotline assistance application for the Province of Cavite.'
                'Developed in collaboration with the Provincial Disaster Risk Reduction Management Office (PDRRMO) of Cavite, '
                'KONTAK is your go-to platform for immediate access to essential emergency services and real-time information during critical situations.'),
            SizedBox(height: 16),
            _buildSectionTitle('Our Mission'),
            _buildSectionContent(
                'Our mission is to provide the residents of the Province of Cavite with a reliable and user-friendly application that ensures timely assistance and vital information in times of need. '
                'Whether it\'s a natural disaster, accident, or any emergency situation, KONTAK is here to connect you with the right resources and services swiftly.'),
            SizedBox(height: 16),
            _buildSectionTitle('Key Features'),
            _buildFeatureList([
              'Emergency Services Access: Quickly connect with fire, police, medical, and disaster response teams through our Services Tab.',
              'Real-Time Updates: Stay informed with the latest news on weather, traffic, and government advisories.',
              'Care Tips: Equip yourself with essential first-aid procedures, evacuation and disaster preparedness tips.',
              'Google Maps Integration: Locate nearby emergency services and your exact location during an emergency.',
            ]),
            SizedBox(height: 16),
            _buildSectionTitle('Our Commitment'),
            _buildSectionContent(
                'KONTAK is committed to ensuring the safety and well-being of every resident of Cavite. By providing quick and easy access to emergency services, we aim to reduce response times and improve the overall effectiveness of disaster and emergency management in our community.'
                '\nStay safe with KONTAK, your partner in emergency response.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey[800],
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.blueGrey[600],
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildFeatureList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '• $feature',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                  textAlign: TextAlign.justify,
                ),
              ))
          .toList(),
    );
  }
}
