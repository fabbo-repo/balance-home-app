import 'dart:ui';
import 'package:balance_home_app/src/core/providers/locale_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_io/io.dart';

class LocaleStateNotifier extends StateNotifier<LocaleState> {
  LocaleStateNotifier() : 
    super(LocaleState(Locale(Platform.localeName.substring(0, 2))));
  
  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  Locale getLocale() {
    return state.locale;
  }
}