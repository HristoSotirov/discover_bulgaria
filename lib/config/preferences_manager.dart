import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discover_bulgaria/config/app_colors.dart';
import 'package:discover_bulgaria/config/app_text_styles.dart';
import 'package:discover_bulgaria/config/free_translation_service.dart';

class PreferencesManager extends ChangeNotifier {
  static final PreferencesManager _instance = PreferencesManager._internal();
  factory PreferencesManager() => _instance;
  
  PreferencesManager._internal() {
    // Initialize preferences immediately when instance is created
    initializePreferences();
  }

  bool _isDarkMode = false;
  String _selectedLanguage = 'bg';
  final Map<String, String> _translationCache = {};
  bool _initialized = false;
  String? _userId;
  bool _isOnboardingDone = false;

  final Map<String, Map<String, String>> languages = {
    'bg': {
      'name': 'Български',
      'symbol': 'БГ',
      'flag': '🇧🇬',
    },
    'en': {
      'name': 'English',
      'symbol': 'EN',
      'flag': '🇺🇸',
    },
  };

  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  Map<String, Color> get currentColors => AppColors.getColors(_isDarkMode);
  Map<String, TextStyle> get currentStyles => AppTextStyles.getStyles(_isDarkMode);
  bool get isLoggedIn => _userId != null;
  String? get userId => _userId;
  bool get isOnboardingDone => _isOnboardingDone;

  Future<void> initializePreferences() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load all preferences at once
      await Future.wait([
        _loadThemePreference(prefs),
        _loadLanguagePreference(prefs),
        _loadUserSession(prefs),
        _loadOnboardingStatus(prefs),
        _loadCachedTranslations(),
      ]);
      
      _initialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing preferences: $e');
      // Set defaults if there's an error
      _isDarkMode = false;
      _selectedLanguage = 'bg';
      _userId = null;
      _isOnboardingDone = false;
      _initialized = true;
    }
  }

  Future<void> _loadThemePreference(SharedPreferences prefs) async {
    _isDarkMode = prefs.getBool('darkMode') ?? false;
  }

  Future<void> _loadLanguagePreference(SharedPreferences prefs) async {
    _selectedLanguage = prefs.getString('language') ?? 'bg';
  }

  Future<void> _loadUserSession(SharedPreferences prefs) async {
    _userId = prefs.getString('userId');
  }

  Future<void> _loadOnboardingStatus(SharedPreferences prefs) async {
    _isOnboardingDone = prefs.getBool('onboardingDone') ?? false;
  }

  Future<void> _loadCachedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final commonPhrases = [
      'Добре дошли!', 'Изберете език', 'Изберете режим', 'Продължи',
      'Нощен режим', 'Дневен режим', 'Вход', 'Имейл', 'Парола', 'Влез',
      'Welcome!', 'Choose Language', 'Choose Mode', 'Continue',
      'Dark Mode', 'Light Mode', 'Login', 'Email', 'Password', 'Sign In'
    ];

    for (var text in commonPhrases) {
      for (var lang in languages.keys) {
        final cached = prefs.getString('translated_${lang}_$text');
        if (cached != null) _translationCache[text] = cached;
      }
    }
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    if (_selectedLanguage == value) return;
    _selectedLanguage = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    notifyListeners();
  }

  Future<String> translate(String text) async {
    if (_selectedLanguage == 'bg') return text;
    if (_translationCache.containsKey(text)) return _translationCache[text]!;

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('translated_${_selectedLanguage}_$text');
    if (cached != null) {
      _translationCache[text] = cached;
      return cached;
    }

    try {
      final translated = await FreeTranslationService.translate(text, _selectedLanguage);
      _translationCache[text] = translated;
      await prefs.setString('translated_${_selectedLanguage}_$text', translated);
      return translated;
    } catch (e) {
      return text;
    }
  }

  Future<void> saveUserSession(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      _userId = userId;
      notifyListeners();
    } catch (e) {
      print('Error saving user session: $e');
      throw e;
    }
  }

  Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      _userId = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing user session: $e');
      throw e;
    }
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    _isOnboardingDone = true;
    notifyListeners();
  }
}

