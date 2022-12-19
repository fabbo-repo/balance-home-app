import 'dart:ui';
import 'package:balance_home_app/src/core/providers/localization/localization_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_io/io.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizationStateNotifier extends StateNotifier<LocalizationState> {
  LocalizationStateNotifier() : 
    super(
      LocalizationState(
        lookupAppLocalizations(
          getLocaleOrDefault(
            Locale(
              Platform.localeName.substring(0, 2)
            )
          )
        )
      )
    );
  
  void setLocalization(Locale locale) {
    Locale checkedLocale = getLocaleOrDefault(locale);
    state = state.copyWith(localization: lookupAppLocalizations(checkedLocale));
  }

  AppLocalizations getLocalization() {
    return state.localization;
  }

  static Locale getLocaleOrDefault(Locale locale) {
    if (AppLocalizations.supportedLocales.contains(locale)){
      return locale;
    }
    return const Locale("es");
  }
}