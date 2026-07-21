import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _defaultUrlKey = "default_url";
  static const _darkModeKey = "dark_mode";
  static const _fontSizeKey = "font_size";
  static const _imageKey = "show_image";

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // -------------------------
  // 기본 URL
  // -------------------------

  static Future<String> getDefaultUrl() async {
    final prefs = await _prefs;

    return prefs.getString(_defaultUrlKey) ??
        "https://www.google.com";
  }

  static Future<void> saveDefaultUrl(String url) async {
    final prefs = await _prefs;

    await prefs.setString(_defaultUrlKey, url);
  }

  // -------------------------
  // 다크모드
  // -------------------------

  static Future<bool> getDarkMode() async {
    final prefs = await _prefs;

    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> saveDarkMode(bool value) async {
    final prefs = await _prefs;

    await prefs.setBool(_darkModeKey, value);
  }

  // -------------------------
  // 글자크기
  // -------------------------

  static Future<double> getFontSize() async {
    final prefs = await _prefs;

    return prefs.getDouble(_fontSizeKey) ?? 18;
  }

  static Future<void> saveFontSize(double value) async {
    final prefs = await _prefs;

    await prefs.setDouble(_fontSizeKey, value);
  }

  // -------------------------
  // 이미지 표시
  // -------------------------

  static Future<bool> getShowImage() async {
    final prefs = await _prefs;

    return prefs.getBool(_imageKey) ?? true;
  }

  static Future<void> saveShowImage(bool value) async {
    final prefs = await _prefs;

    await prefs.setBool(_imageKey, value);
  }
}