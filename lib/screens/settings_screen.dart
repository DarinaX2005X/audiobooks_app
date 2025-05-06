import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import 'login_screen.dart';

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
                // Appearance Section
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

                // Language Section
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Notifications Section
                Text(
                  loc.notifications,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.enableNotifications,
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: Switch(
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      settings.setNotificationsEnabled(value);
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Reading Preferences Section
                Text(
                  loc.readingPreferences,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.fontSizeSmall,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: 'small',
                    groupValue: settings.fontSize,
                    onChanged: (value) {
                      settings.setFontSize('small');
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.fontSizeMedium,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: 'medium',
                    groupValue: settings.fontSize,
                    onChanged: (value) {
                      settings.setFontSize('medium');
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.fontSizeLarge,
                    style: theme.textTheme.bodyLarge,
                  ),
                  leading: Radio<String>(
                    value: 'large',
                    groupValue: settings.fontSize,
                    onChanged: (value) {
                      settings.setFontSize('large');
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Data Sync Section
                Text(
                  loc.dataSync,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.enableDataSync,
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: Switch(
                    value: settings.dataSyncEnabled,
                    onChanged: (value) {
                      settings.setDataSyncEnabled(value);
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // Account Section
                Text(
                  loc.account,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppTextStyles.albraFontFamily,
                  ),
                ),
                ListTile(
                  title: Text(
                    loc.logout,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(loc.logout),
                        content: Text(loc.logoutConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(loc.cancel),
                          ),
                          TextButton(
                            onPressed: () async {
                              await AuthService.logout();
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                );
                              }
                            },
                            child: Text(
                              loc.logout,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}