import 'package:balance_home_app/src/core/providers/locale_state.dart';
import 'package:balance_home_app/src/core/providers/locale_state_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;

/// Observer used to notify the caller when the locale changes
class _LocaleObserver extends WidgetsBindingObserver {
  
  final void Function(List<Locale>? locales) _didChangeLocales;

  _LocaleObserver(this._didChangeLocales);
  
  @override
  void didChangeLocales(List<Locale>? locales) {
    _didChangeLocales(locales);
  }
}

/// Provider used to access the AppLocalizations object for the current locale
final appLocalizationsProvider = Provider<AppLocalizations>(
  (ProviderRef<AppLocalizations> ref) {
    // Initialize from the initial locale
    ref.state = lookupAppLocalizations(ui.window.locale);
    // Create an observer to update the state
    final observer = _LocaleObserver((locales) {
      ref.state = lookupAppLocalizations(ui.window.locale);
    });
    // Register the observer and dispose it when no longer needed
    final binding = WidgetsBinding.instance;
    binding.addObserver(observer);
    ref.onDispose(() => binding.removeObserver(observer));
    // Return the state
    return ref.state;
  }
);

/// StateNotifier
final localeStateNotifierProvider = StateNotifierProvider<LocaleStateNotifier, LocaleState>(
  (StateNotifierProviderRef<LocaleStateNotifier, LocaleState> ref) => 
    LocaleStateNotifier()
);