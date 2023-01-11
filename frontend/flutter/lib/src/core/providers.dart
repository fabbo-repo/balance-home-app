import 'package:balance_home_app/config/providers.dart';
import 'package:balance_home_app/src/core/application/app_version_controller.dart';
import 'package:balance_home_app/src/core/domain/repositories/app_info_repository_interface.dart';
import 'package:balance_home_app/src/core/infrastructure/repositories/app_info_repository.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:balance_home_app/src/core/presentation/states/app_localizations_state.dart';
import 'package:balance_home_app/src/core/presentation/states/theme_mode_state.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_io/io.dart';

///
/// Infrastructure dependencies
///

final appInfoRepositoryProvider = Provider<AppInfoRepositoryInterface>((ref) {
  return AppInfoRepository(httpService: ref.read(httpServiceProvider));
});

///
/// Application dependencies
///

final appVersionController =
    StateNotifierProvider<AppVersionController, AsyncValue<AppVersion>>((ref) {
  final repo = ref.watch(appInfoRepositoryProvider);
  return AppVersionController(repo);
});

///
/// Presentation dependencies
///

final themeModeProvider =
    StateNotifierProvider<ThemeModeState, ThemeMode>((ref) {
  final settingsRepository = ref.read(settingsRepositoryProvider);
  final theme = settingsRepository.getTheme().fold((l) {
    return (SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light)
        ? ThemeMode.light
        : ThemeMode.dark;
  }, (r) => r);
  return ThemeModeState(theme);
});

final appLocalizationsProvider =
    StateNotifierProvider<AppLocalizationsState, AppLocalizations>((ref) {
  Locale locale = Locale(Platform.localeName.substring(0, 2));
  // If system's locale is not supported, Enlish will be used as default
  if (!AppLocalizations.supportedLocales.contains(locale)) {
    locale = const Locale("en");
  }
  return AppLocalizationsState(lookupAppLocalizations(locale));
});
