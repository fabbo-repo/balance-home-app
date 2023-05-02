import 'package:balance_home_app/config/providers.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BalanceHomeApp extends ConsumerStatefulWidget {
  const BalanceHomeApp({super.key});

  @override
  BalanceHomeAppState createState() => BalanceHomeAppState();
}

class BalanceHomeAppState extends ConsumerState<BalanceHomeApp> {
  @override
  Widget build(BuildContext context) {
    // Change language header if aplication language changes
    ref
        .read(apiClientProvider)
        .setLanguage(ref.read(appLocalizationsProvider).localeName);
    ref.listen(appLocalizationsProvider, (previous, next) {
      debugPrint(
          "[PROVIDER LISTENER] New Accept-Language value: ${next.localeName}");
      ref.read(apiClientProvider).setLanguage(next.localeName);
    });
    // Change theme
    ref.read(settingsRepositoryProvider).getTheme().then((value) {
      value.fold((_) => null, (theme) {
        ref.read(themeDataProvider.notifier).setThemeData(theme);
      });
    });
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ref.watch(themeDataProvider),
        onGenerateTitle: (context) {
          // In the app build, the context does not contain an AppLocalizations instance.
          // However, at the moment the title is ggoing to be generated
          // the AppLocalizations instance is not null
          final appLocalizations = ref.read(appLocalizationsProvider);
          return appLocalizations.appTitle;
        },
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        routeInformationProvider: router.routeInformationProvider,
        backButtonDispatcher: router.backButtonDispatcher);
  }
}
