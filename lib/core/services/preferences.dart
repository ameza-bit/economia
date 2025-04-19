import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences pref;

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
    showedSplash = false;
  }

  static Future<void> logOut() async {
    pref.getKeys().forEach((key) async {
      if (!key.contains("ND_")) await deleted(key);
    });
  }

  static Future<void> deleted(String key) async {
    if (pref.containsKey(key)) {
      if (key.contains("IMG_")) {
        String? path = pref.getString(key);
        try {
          if (path != null) {
            File file = File(path);
            await file.delete();
          }
        } catch (e) {
          Exception("Delete file: $e");
        }
      }
      await pref.remove(key);
    }
  }

  /// Valida si se ha mostrado el splash.
  static bool get showedSplash => pref.getBool('ND_showedSplash') ?? false;
  static set showedSplash(bool value) => pref.setBool('ND_showedSplash', value);

  static Future<void> reload() async => await pref.reload();

  static String getString(String key) => pref.getString(key) ?? "";

  static int getInt(String key) => pref.getInt(key) ?? 0;

  static bool getBool(String key) => pref.getBool(key) ?? false;

  static void setString(String key, String value) => pref.setString(key, value);

  static void setInt(String key, int value) => pref.setInt(key, value);

  static void setBool(String key, bool value) => pref.setBool(key, value);
}
