import 'package:flutter/services.dart';
import 'package:kontak_application_2/services/call_receiver.dart';
import 'package:kontak_application_2/services/database.dart';

class PhoneStateListener {
  static const MethodChannel _channel = MethodChannel('phoneStateListener');

  static void init(String userId, String name, String address, String email,
      String contact) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onCallStateChanged") {
        String state = call.arguments;
        print("Call state changed: $state"); // Debugging line

        if (state == "CALL_CONNECTED") {
          print("Call connected");
          CallReceiver.referenceNumber = CallReceiver.generateReferenceNumber(
              userId, name, address, email, contact); // Pass user details
          print("Reference Number: ${CallReceiver.referenceNumber}");

          // Save the reference number and user details to Firestore
          await DatabaseMethods.saveEmergencyIncident(
            CallReceiver.referenceNumber!,
            userId,
            name,
            address,
            email,
            contact,
            CallReceiver.emergencyNumber,
          );
        } else if (state == "CALL_ENDED") {
          print("Call ended");
          CallReceiver.referenceNumber =
              null; // Optionally reset the reference number
        } else {
          print("Other Call State: $state"); // Log any other call states
        }
      }
    });
  }
}
