import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          loc.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: AppTextStyles.albraFontFamily,
          ),
        ),
        backgroundColor: theme.colorScheme.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.appearance,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.lightTheme,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      settings.setThemeMode(ThemeMode.light);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.darkTheme,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      settings.setThemeMode(ThemeMode.dark);
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(
                  loc.language,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.english,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: 'en',
                    groupValue: settings.locale.languageCode,
                    onChanged: (value) {
                      settings.setLocale('en');
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.russian,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: 'ru',
                    groupValue: settings.locale.languageCode,
                    onChanged: (value) {
                      settings.setLocale('ru');
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.kazakh,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: 'kk',
                    groupValue: settings.locale.languageCode,
                    onChanged: (value) {
                      settings.setLocale('kk');
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Extra space for navbar
              ],
            ),
          ),
        ),
      ),
    );
  }
}