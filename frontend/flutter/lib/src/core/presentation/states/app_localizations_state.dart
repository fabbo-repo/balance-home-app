import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppLocalizationsState extends StateNotifier<AppLocalizations> {

  AppLocalizationsState(AppLocalizations appLocalizations) : super(appLocalizations);

  void setAppLocalizations(AppLocalizations appLocalizations) {
    state = appLocalizations;
  }
  
  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      locale = const Locale("en");
    }
    state = lookupAppLocalizations(locale);
  }
}
