import 'package:kontak_application_2/responders/responders_database.dart';
import 'package:phone_state/phone_state.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  bool _isListening = false;
  bool _incidentCreated = false;
  bool _isCallActive = false;

  factory CallService() {
    return _instance;
  }

  CallService._internal();

  void startListening(
    Function(String) onCallConnected,
    String emergencyNumber,
    String userId,
    String userName,
    String userAddress,
    String userContact,
    String userProfilePic,
    String? description,
    double latitude,
    double longitude,
    String stationID,
  ) {
    if (!_isListening) {
      // Start listening only if we're not already listening
      _isListening = true;
      print('Listening to phone state changes...');

      // Start listening to the phone state stream
      PhoneState.stream.listen((event) {
        print('Received phone state: ${event.status}');

        if (event.status == PhoneStateStatus.CALL_STARTED) {
          // If a call started and we're not in an active call, handle it
          if (!_isCallActive && !_incidentCreated) {
            _isCallActive = true; // Mark call as active

            // Create the incident for this call
            print('Creating incident for the call...');
            createIncidentAndFetchDateTime(
              emergencyNumber,
              userId,
              userName,
              userAddress,
              userContact,
              userProfilePic,
              description,
              latitude,
              longitude,
              stationID,
            );

            // Mark the incident as created
            _incidentCreated = true;

            // Notify that the call is connected
            onCallConnected(event.status.toString());
          }
        } else if (event.status == PhoneStateStatus.CALL_ENDED) {
          // Only handle CALL_ENDED once
          if (_isCallActive) {
            // Reset everything after the call ends
            _isCallActive = false; // Mark the call as ended
            _incidentCreated = false; // Reset incident creation flag
            _isListening = false; // Stop listening after the call ends
            print('Call ended, resetting...');
          }
        }
      });
    } else {
      print('Already listening, no need to start again.');
    }
  }

  Future<void> createIncidentAndFetchDateTime(
    String emergencyNumber,
    String userId,
    String userName,
    String userAddress,
    String userContact,
    String userProfilePic,
    String? description,
    double latitude,
    double longitude,
    String stationID,
  ) async {
    RespondentDatabase respondentDatabase = RespondentDatabase();
    await respondentDatabase.createIncidentAndFetchDateTime(
        emergencyNumber,
        userId,
        userName,
        userAddress,
        userContact,
        userProfilePic,
        description,
        latitude,
        longitude,
        stationID);
  }
}
