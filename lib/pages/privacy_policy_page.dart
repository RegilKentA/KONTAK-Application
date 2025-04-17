// about_us_page.dart
import 'package:flutter/material.dart';
import 'package:kontak_application_2/components/custom_backbutton_white.dart';

class PrivacyAndPolicy extends StatelessWidget {
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
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color.fromRGBO(202, 230, 241, 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('Privacy Policy'),
            _buildSectionContent(
                'KONTAK is committed to protecting your privacy. This Privacy Policy explains how we collect, use, share, and protect your personal information when you use our application. By using KONTAK, you agree to the collection and use of your information in accordance with this policy.'),
            SizedBox(height: 16),
            _buildSectionTitle('1. Information We Collect'),
            _buildSectionContent(
                'We collect information to provide and improve our services, including:'),
            _buildSectionSubTitle('\nPersonal Information'),
            _buildSectionContent(
                'When you create an account, we collect information such as your full name, address, phone number, email address, and emergency contacts.'),
            _buildSectionSubTitle('\nGeolocation Data '),
            _buildSectionContent(
                'We collect real-time location information through Google Maps when you use our location-based services.'),
            _buildSectionSubTitle('\nUsage Information'),
            _buildSectionContent(
                'We collect data about how you interact with the application, such as which features you use, interaction logs, and details about emergency services accessed.'),
            SizedBox(height: 16),
            _buildSectionTitle('2. How We Use Your Information'),
            _buildSectionContent(
                'We use the information collected for the following purposes:'),
            _buildSectionSubTitle('\nService Delivery'),
            _buildSectionContent(
                'To provide emergency assistance services, which includes locating emergency services and resources, managing user accounts, and enabling responders to access user details during emergencies.'),
            _buildSectionSubTitle('\nCommunication'),
            _buildSectionContent(
                'To notify you about important updates to the application or our policies.'),
            _buildSectionSubTitle('\nData Analysis'),
            _buildSectionContent(
                'To analyze usage patterns and improve our services, generate reports for the Provincial Disaster Risk Reduction Management Officers (PDRRMO), and enhance the user experience.'),
            SizedBox(height: 16),
            _buildSectionTitle('3. Sharing of Information'),
            _buildSectionContent(
                'Your information may be shared under the following circumstances:'),
            _buildSectionSubTitle('\nEmergency Situations'),
            _buildSectionContent(
                'Emergency responders may access your shared location and relevant information when you request assistance.'),
            _buildSectionSubTitle('\nThird-Party Services'),
            _buildSectionContent(
                'We use Google Maps for geolocation services, and Firebase for data storage and management. These third-party services are governed by their respective privacy policies.'),
            _buildSectionSubTitle('\nLegal Requirements'),
            _buildSectionContent(
                'We may disclose your information if required by law or in response to legal processes.'),
            SizedBox(height: 16),
            _buildSectionTitle('4. Data Security'),
            _buildSectionContent(
                'We take data security seriously and implement appropriate measures to protect your personal information from unauthorized access, alteration, disclosure, or destruction. This includes using secure servers and encryption for data storage.'),
            SizedBox(height: 16),
            _buildSectionTitle('5. Data Retention'),
            _buildSectionContent(
                'Your information will be retained for as long as your account is active or as necessary to provide you with services. You can delete your account by accessing your account settings. The safe deletion of your information will comply with legal requirements.'),
            SizedBox(height: 16),
            _buildSectionTitle("6. Children's Privacy"),
            _buildSectionContent(
                'KONTAK is intended for users aged 18 and above. Minors are allowed to use the application only under the supervision of a parent or legal guardian. We do not knowingly collect personal information from children under 18 without parental consent.'),
            SizedBox(height: 16),
            _buildSectionTitle('7. User Rights'),
            _buildSectionContent('You have the right to:'),
            _buildSectionSubTitle(
                '\nAccess, Update, and Delete your Information'),
            _buildSectionContent(
                'You can view, update, or delete your personal information through your account settings.'),
            _buildSectionSubTitle('\nWithdraw Consent'),
            _buildSectionContent(
                'You can withdraw your consent to the collection and use of your information at any time by discontinuing the use of the application.'),
            SizedBox(height: 16),
            _buildSectionTitle('8. Changes to the Privacy Policy'),
            _buildSectionContent(
                'We may update this Privacy Policy from time to time. Any changes will be communicated through the application or by email. Your continued use of the application after such changes will constitute your acceptance of the updated Privacy Policy.'),
            SizedBox(height: 16),
            _buildSectionTitle('Contact Us'),
            _buildSectionContent(
                'If you have any questions or concerns about this Privacy Policy, please contact us via email at [kontakmain90@gmail.com].'),
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

  Widget _buildSectionSubTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
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
                ),
              ))
          .toList(),
    );
  }
}
