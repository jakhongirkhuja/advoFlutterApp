import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const List<String> supportedLanguageCodes = [
    'uz',
    'en',
    'ru',
    'ko',
    'tr',
    'ar',
    'de',
    'zh',
  ];

  static const List<Map<String, String>> supportedLanguages = [
    {'name': 'O\'zbekcha', 'code': 'uz', 'flag': '🇺🇿'},
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Русский', 'code': 'ru', 'flag': '🇷🇺'},
    {'name': '한국어', 'code': 'ko', 'flag': '🇰🇷'},
    {'name': 'Türkçe', 'code': 'tr', 'flag': '🇹🇷'},
    {'name': 'العربية', 'code': 'ar', 'flag': '🇸🇦'},
    {'name': 'Deutsch', 'code': 'de', 'flag': '🇩🇪'},
    {'name': '中文', 'code': 'zh', 'flag': '🇨🇳'},
  ];

  Locale? _locale;

  Locale? get locale => _locale;
  String? get currentLanguageCode => _locale?.languageCode;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    if (!supportedLanguageCodes.contains(locale.languageCode)) return;

    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  void clearLocale() async {
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
    notifyListeners();
  }
}
