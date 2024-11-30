// import 'package:shared_preferences/shared_preferences.dart';

// class LocalStorage {
//   static SharedPreferences? _prefs;

//   static Future<String?> read(String key) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     return _prefs!.getString(key);
//   }

//   static Future<void> write(String key, String value) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     _prefs!.setString(key, value);
//   }

//   static Future<void> remove(String key) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     _prefs!.remove(key);
//   }

//   static Future<bool> exists(String key) async {
//     _prefs ??= await SharedPreferences.getInstance();
//     return _prefs!.containsKey(key);
//   }
// }
