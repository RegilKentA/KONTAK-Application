import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Check if phone permission is granted
  static Future<bool> checkPhonePermission() async {
    var status = await Permission.phone.status;
    return status.isGranted; // Returns true if the phone permission is granted
  }

  // Check if location permission is granted
  static Future<bool> checkLocationPermission() async {
    var status = await Permission.location.status;
    return status
        .isGranted; // Returns true if the location permission is granted
  }

  // Request phone permission
  static Future<bool> requestPhonePermission() async {
    var status = await Permission.phone.status;

    if (status.isGranted) {
      return true; // Permission already granted
    } else if (status.isDenied) {
      // Request permission
      var result = await Permission.phone.request();
      return result.isGranted; // Return whether the permission is granted
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, provide a way to open settings
      return false;
    }

    return false; // In case of any other status
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.location.status;

    if (status.isGranted) {
      return true; // Permission already granted
    } else if (status.isDenied) {
      // Request permission
      var result = await Permission.location.request();
      return result.isGranted; // Return whether the permission is granted
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, provide a way to open settings
      return false;
    }

    return false; // In case of any other status
  }

  // Check if phone permission is permanently denied
  static Future<bool> isPhonePermissionPermanentlyDenied() async {
    var status = await Permission.phone.status;
    return status
        .isPermanentlyDenied; // Returns true if the permission is permanently denied
  }

  // Check if location permission is permanently denied
  static Future<bool> isLocationPermissionPermanentlyDenied() async {
    var status = await Permission.location.status;
    return status
        .isPermanentlyDenied; // Returns true if the permission is permanently denied
  }
}
