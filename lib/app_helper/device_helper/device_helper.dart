import 'dart:io';
import 'package:chronogram/app_helper/app_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DeviceHelper {
  static Future<Map<String, dynamic>> getDeviceData() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceId = "";
    String deviceModel = "";
    String osVersion = "";
    double latitude = 0.0;
    double longitude = 0.0;
    String country = "";
    String city = "";

    try {
      // 1. Try to get real GPS Location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (serviceEnabled && (permission == LocationPermission.always || permission == LocationPermission.whileInUse)) {
        try {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
              .timeout(const Duration(seconds: 4));
          latitude = position.latitude;
          longitude = position.longitude;
          
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
            if (placemarks.isNotEmpty) {
              Placemark place = placemarks[0];
              city = place.locality ?? place.subAdministrativeArea ?? "";
              country = place.country ?? "";
            }
          } catch (e) {
            print("Geocoding Error: $e");
          }
        } catch (e) {
          print("GPS fetch timeout/error, falling back to IP: $e");
        }
      }
      
      // Fallback to IP Geolocation if GPS is denied or failed
      if (latitude == 0.0 && longitude == 0.0) {
        final ipResponse = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 4));
        if (ipResponse.statusCode == 200) {
          final data = jsonDecode(ipResponse.body);
          latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
          longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;
          country = data['country_name'] ?? "";
          city = data['city'] ?? "";
        }
      }
    } catch (e) {
      print("Location fetch error: $e");
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo android = await deviceInfo.androidInfo;
      deviceId = android.id;
      deviceModel = android.model;
      osVersion = android.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo ios = await deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ?? "";
      deviceModel = ios.model;
      osVersion = ios.systemVersion;
    }

    final uuid = await AppHelper().getDeviceUUID();

    final deviceData = {
      "deviceId": deviceId,
      "deviceName": deviceModel,
      "simSerial": uuid,
      "deviceModel": deviceModel,
      "osName": Platform.isAndroid ? "Android" : "iOS",
      "osVersion": osVersion,
      "appVersion": packageInfo.version,
      "latitude": latitude,
      "longitude": longitude,
      if (country.isNotEmpty) "country": country,
      if (city.isNotEmpty) "city": city,
    };

    print("DEVICE DATA GATHERED: $deviceData");

    return deviceData;
  }
}
