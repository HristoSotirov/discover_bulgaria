import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discover_bulgaria/config/app_colors.dart';
import 'package:discover_bulgaria/config/app_text_styles.dart';
import 'package:discover_bulgaria/config/free_translation_service.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedLanguage = 'bg';
  bool _isDarkMode = false;
  final Map<String, String> _translationCache = {};

  final Map<String, Map<String, String>> _languages = {
    'bg': {'name': 'Български', 'flag': '🇧🇬'},
    'en': {'name': 'English', 'flag': '🇬🇧'},
  };

  Map<String, Color> get _currentColors => AppColors.getColors(_isDarkMode);
  Map<String, TextStyle> get _currentStyles => AppTextStyles.getStyles(_isDarkMode);

  Future<String> _translate(String text) async {
    if (_selectedLanguage == 'bg') return text;
    if (_translationCache.containsKey(text)) return _translationCache[text]!;

    try {
      final translated = await FreeTranslationService.translate(text, _selectedLanguage);
      _translationCache[text] = translated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('translated_${_selectedLanguage}_$text', translated);
      return translated;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('translated_${_selectedLanguage}_$text') ?? text;
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setBool('darkMode', _isDarkMode);
  }

  @override
  void initState() {
    super.initState();
    _loadCachedTranslations();
  }

  Future<void> _loadCachedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    for (var text in ['Добре дошли!', 'Изберете език', 'Изберете режим', 'Продължи', 'Нощен режим', 'Дневен режим']) {
      for (var lang in _languages.keys) {
        final cached = prefs.getString('translated_${lang}_$text');
        if (cached != null) _translationCache[text] = cached;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentColors['background'],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: Future.wait([
            _translate('Добре дошли!'),
            _translate('Изберете език'),
            _translate('Изберете режим'),
            _translate('Продължи'),
            _translate(_isDarkMode ? 'Нощен режим' : 'Дневен режим'),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return _buildLoading();

            final data = snapshot.data as List<String>;
            return _buildContent(data[0], data[1], data[2], data[3], data[4]);
          },
        ),
      ),
    );
  }

  Widget _buildLoading() => Center(
    child: CircularProgressIndicator(color: _currentColors['background']),
  );

  Widget _buildContent(String welcome, String chooseLang, String chooseMode, String continueText, String modeText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(welcome, style: _currentStyles['headingLarge']),
        SizedBox(height: 40),
        _buildLanguageSelector(chooseLang),
        SizedBox(height: 20),
        _buildThemeSelector(chooseMode, modeText),
        SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentColors['button'],
            foregroundColor: _currentColors['text'],
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _navigateToLoginScreen,
          child: Text(continueText),
        ),
      ],
    );
  }

  void _navigateToLoginScreen() {
    _savePreferences();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  Widget _buildLanguageSelector(String title) => Column(
    children: [
      Text(title, style: _currentStyles['bodyRegular']),
      SizedBox(height: 15),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _languages.entries.map((e) => _LanguageButton(
          label: '${e.value['flag']} ${e.value['name']}',
          value: e.key,
          selected: _selectedLanguage == e.key,
          onSelected: (v) => setState(() => _selectedLanguage = v),
          colors: _currentColors,
        )).toList(),
      ),
    ],
  );

  Widget _buildThemeSelector(String title, String modeText) => Column(
    children: [
      Text(title, style: _currentStyles['bodyRegular']),
      SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 60, vertical: 0),
        dense: true,
        visualDensity: VisualDensity.compact,
        title: Text(modeText, style: _currentStyles['bodyRegular']),
        value: _isDarkMode,
        activeColor: _currentColors['background'],
        activeTrackColor: _currentColors['button']?.withOpacity(0.3),
        inactiveThumbColor: _currentColors['button'],
        inactiveTrackColor: _currentColors['background']?.withOpacity(0.5),
        onChanged: (v) => setState(() => _isDarkMode = v),
      ),
    ],
  );
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(String) onSelected;
  final Map<String, Color> colors;

  const _LanguageButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = colors['primary'] ?? Colors.blue;
    final textColor = colors['text'] ?? Colors.black;
    final cardColor = colors['background'] ?? Colors.white;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: primaryColor.withOpacity(0.3),
      labelStyle: TextStyle(color: selected ? primaryColor : textColor),
      backgroundColor: cardColor,
      onSelected: (_) => onSelected(value),
    );
  }
}
