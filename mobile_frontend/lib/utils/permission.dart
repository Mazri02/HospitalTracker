import 'package:location/location.dart';

class Permission {
  // Ini bahagian permission untuk location
  Location location = Location();
  LocationData? locationData;

  Future<bool> requestPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false; // Location services are not enabled
      }
    }

    // Check if permissions are granted
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false; // Permissions are not granted
      }
    }

    return true; // All permissions granted
  }

  Future<LocationData?> getLocation() async {
    try {
      return await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Any else
}
