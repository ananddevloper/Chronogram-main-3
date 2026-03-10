import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AppHelper {
  
 Future<String> getDeviceUUID() async {
  final prefs = await SharedPreferences.getInstance();
  String? uuid = prefs.getString('device_id');

  if (uuid == null) {
    uuid = const Uuid().v4();
    await prefs.setString('device_id', uuid);
  }
  return uuid;
}
  
}