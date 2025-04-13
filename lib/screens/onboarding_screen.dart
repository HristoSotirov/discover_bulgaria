import 'package:flutter/material.dart';
import 'package:discover_bulgaria/config/preferences_manager.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _prefsManager = PreferencesManager();

  @override
  void initState() {
    super.initState();
    // Remove the listener since it's not needed for translations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _prefsManager.currentColors['background'],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: Future.wait([
            _prefsManager.translate('Добре дошли!'),
            _prefsManager.translate('Изберете език'),
            _prefsManager.translate('Изберете режим'),
            _prefsManager.translate('Продължи'),
            _prefsManager.translate(_prefsManager.isDarkMode ? 'Тъмен режим' : 'Светъл режим'),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(
              child: CircularProgressIndicator(
                color: _prefsManager.currentColors['button']
              ),
            );

            final data = snapshot.data as List<String>;
            return _buildContent(data[0], data[1], data[2], data[3], data[4]);
          },
        ),
      ),
    );
  }

  Widget _buildContent(String welcome, String chooseLang, String chooseMode, 
                      String continueText, String modeText) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(welcome, style: _prefsManager.currentStyles['headingLarge']),
        SizedBox(height: 40),
        _buildLanguageSelector(chooseLang),
        SizedBox(height: 20),
        _buildThemeSelector(chooseMode, modeText),
        SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _prefsManager.currentColors['button'],
            foregroundColor: _prefsManager.currentColors['background'],
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            await _prefsManager.setOnboardingDone();
            if (!mounted) return;
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => LoginScreen())
            );
          },
          child: Text(continueText),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(String title) => Column(
    children: [
      Text(title, style: _prefsManager.currentStyles['bodyRegular']),
      SizedBox(height: 15),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _prefsManager.languages.entries.map((e) => _LanguageButton(
          label: '${e.value['flag']} ${e.value['name']}',
          value: e.key,
          selected: _prefsManager.selectedLanguage == e.key,
          onSelected: (v) {
            setState(() {
              _prefsManager.setLanguage(v);
            });
          },
          colors: _prefsManager.currentColors,
        )).toList(),
      ),
    ],
  );

  Widget _buildThemeSelector(String title, String modeText) => Column(
    children: [
      Text(title, style: _prefsManager.currentStyles['bodyRegular']),
      SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 60),
        title: Text(modeText, style: _prefsManager.currentStyles['bodyRegular']),
        value: _prefsManager.isDarkMode,
        activeColor: _prefsManager.currentColors['button'],
        activeTrackColor: _prefsManager.currentColors['accent']?.withOpacity(0.3),
        inactiveThumbColor: _prefsManager.currentColors['button'],
        inactiveTrackColor: _prefsManager.currentColors['background']?.withOpacity(0.5),
        onChanged: (v) {
          setState(() {
            _prefsManager.setDarkMode(v);
          });
        },
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
    final primaryColor = colors['button'] ?? Colors.blue;
    final backgroundColor = colors['background'] ?? Colors.white;
    final textColor = colors['text'] ?? Colors.black;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: primaryColor,
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: selected ? backgroundColor : textColor,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      side: BorderSide(
        color: selected ? primaryColor : colors['box'] ?? Colors.grey,
      ),
      onSelected: (_) => onSelected(value),
    );
  }
}
