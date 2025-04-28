import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart' as gen;

class AppLocalizations {
  static const LocalizationsDelegate<gen.AppLocalizations> delegate = gen.AppLocalizations.delegate;

  static gen.AppLocalizations of(BuildContext context) {
    final localizations = gen.AppLocalizations.of(context);
    if (localizations == null) {
      throw Exception('AppLocalizations not found in context');
    }
    return localizations;
  }

  static List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('ru'),
    Locale('kk'),
  ];
}