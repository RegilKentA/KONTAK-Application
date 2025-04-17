import 'package:flutter/material.dart';
import 'package:kontak_application_2/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Color.fromRGBO(202, 230, 241, 1),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TERMS AND CONDITIONS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'KONTAK, an Android Emergency and Hotline Assistance Application is developed for the residents of the Province of Cavite.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('Acceptance of Terms'),
              _buildSectionContent(
                'By using KONTAK, you certify that you have read and agreed to these Terms and Conditions, which constitute a binding agreement between you and the KONTAK development team. If you do not agree with these terms, you are advised to not use the application.',
              ),
              SizedBox(height: 8),
              _buildSectionTitle('KONTAK only grants the following:'),
              _buildSectionTitle('1. Eligibility'),
              _buildSectionContent(
                'This application is intended for use by the residents of the Province of Cavite. Users must be at least 18 years old to create an account. Minors are allowed to use the application under the supervision of a parent or legal guardian.',
              ),
              _buildSectionTitle('2. Account Registration'),
              _buildSectionContent(
                'To access certain features of the application, you must create an account using your phone number or email address. You agree to provide accurate and complete information during the registration process. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.',
              ),
              _buildSectionTitle('3. Use of the Application'),
              _buildSectionContent(
                'KONTAK is designed to assist residents in accessing emergency services and hotlines. The application provides information and resources related to emergency response, including:\n\n- Real-time location services using Google Maps.\n- Directories of emergency services, including fire, police, medical, and disaster response.\n- Emergency preparedness resources, including first aid procedures and evacuation plans.\n- Local news updates related to emergencies.',
              ),
              _buildSectionTitle('4. Limitations of Use'),
              _buildSectionContent(
                "The KONTAK application is limited to providing contact information and resources for emergencies within the Province of Cavite. When using the emergency or call buttons, users will be redirected to their phone's dialing application and will add usage to their cellular data. Other features of the application may require the use of internet connection.",
              ),
              _buildSectionTitle('5. User Content'),
              _buildSectionContent(
                'Users may have the ability to input and modify personal information, including emergency contacts. You agree not to post any content that is unlawful, harmful, or violates the rights of others. The development team reserves the right to remove or modify any content that violates these terms.',
              ),
              _buildSectionTitle('6. Privacy Policy'),
              _buildSectionContent(
                'Your use of KONTAK is also governed by our Privacy Policy, which outlines how your personal information is collected, used, and protected. By using the application, you consent to the collection and use of your information as described in the Privacy Policy.',
              ),
              _buildSectionTitle('7. Third-Party Services'),
              _buildSectionContent(
                'KONTAK uses third-party geolocation software, specifically, Google Maps, to provide real-time location services. By using the application, you agree to the terms of service of these third-party providers.',
              ),
              _buildSectionTitle('8. Reports and Data Management'),
              _buildSectionContent(
                'Administrators can generate reports based on user interactions with the application. These reports may include user details and interaction logs, which are stored securely within the Firebase database. By using KONTAK, you consent to the collection and use of your information.',
              ),
              _buildSectionTitle('9. Application Updates'),
              _buildSectionContent(
                'The KONTAK development team may release updates or modifications to the application. Users are encouraged to download and install these updates to ensure the application functions properly.',
              ),
              _buildSectionTitle('10. Disclaimer of Warranties'),
              _buildSectionContent(
                'KONTAK is provided "as is" without any warranties of any kind, either express or implied. The development team does not guarantee the accuracy or completeness of the information provided in the application.',
              ),
              _buildSectionTitle('11. Limitation of Liability'),
              _buildSectionContent(
                'To the fullest extent permitted by law, the KONTAK development team shall not be liable for any damages resulting from the use or inability to use the application, including but not limited to direct, indirect, incidental, or consequential damages.',
              ),
              _buildSectionTitle('12. Governing Law'),
              _buildSectionContent(
                'These Terms and Conditions are governed by and construed in accordance with the data privacy laws of the Philippines. Any disputes arising out of or in connection with these terms shall be subject to the exclusive jurisdiction of the courts located in the Province of Cavite.',
              ),
              _buildSectionTitle('13. Modifications to Terms and Conditions'),
              _buildSectionContent(
                'The KONTAK development team reserves the right to modify these Terms and Conditions at any time. Users will be notified of any changes through the application or by email. Continued use of the application after such changes constitutes acceptance of the new terms.',
              ),
              _buildSectionTitle('Contact Us'),
              _buildSectionContent(
                'For any questions or concerns about these Terms and Conditions, please contact the KONTAK support team via email at [litomaligro222@gmail.com].',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color.fromRGBO(202, 230, 241, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Save the flag and navigate to the authentication page
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('terms_accepted', true);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthService()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Accept',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Exit the application
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 14, color: Colors.black54),
      textAlign: TextAlign.justify,
    );
  }
}
