import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const List<String> supportedLanguageCodes = [
    'uz',
    'en',
    'ru',
  ];

  static const List<Map<String, String>> supportedLanguages = [
    {'name': 'O\'zbekcha', 'code': 'uz', 'flag': '🇺🇿'},
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Русский', 'code': 'ru', 'flag': '🇷🇺'},
  ];

  Locale _locale = const Locale('uz');

  Locale get locale => _locale;
  String get currentLanguageCode => _locale.languageCode;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null && supportedLanguageCodes.contains(languageCode)) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = const Locale('uz');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
    notifyListeners();
  }
}
