import 'dart:math';
import 'package:flutter/services.dart';

class CallReceiver {
  static const MethodChannel _channel = MethodChannel('callReceiver');
  static String emergencyNumber = "";
  static String? referenceNumber;
  static Function? onValidCall;

  static void init(String number, {Function? onCallConfirmed}) {
    emergencyNumber = number;
    print("Emergency Number: $emergencyNumber"); // Debugging print
    onValidCall = onCallConfirmed;

    _channel.setMethodCallHandler((call) async {
      if (call.method == "onCallOutgoing") {
        String outgoingNumber = call.arguments['number'];
        print(
            'Outgoing Number: $outgoingNumber, Expected: $emergencyNumber'); // Log numbers being compared

        if (checkNumber(outgoingNumber)) {
          print('Correct emergency number called.');
          onValidCall?.call(); // Call the callback if the number is valid
        } else {
          print("Alert: Outgoing number is incorrect!");
        }
      }
    });
  }

  static bool checkNumber(String number) {
    // Normalize both numbers by removing non-digit characters
    String normalizedNumber = number.replaceAll(RegExp(r'\D'), '');
    String normalizedEmergencyNumber =
        emergencyNumber.replaceAll(RegExp(r'\D'), '');

    print(
        'Normalized Outgoing Number: $normalizedNumber, Normalized Emergency Number: $normalizedEmergencyNumber'); // Debugging normalization

    return normalizedNumber ==
        normalizedEmergencyNumber; // Compare the outgoing number with the normalized emergency number
  }

  static String generateReferenceNumber(String userId, String name,
      String address, String email, String contact) {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    int randomNumber =
        Random().nextInt(1000); // Random number between 0 and 999
    String refNum =
        "$timestamp-$randomNumber-$userId-$name-$address-$email-$contact";
    print(
        'Generated Reference Number: $refNum'); // Log the generated reference number
    return refNum; // Return the reference number
  }
}
