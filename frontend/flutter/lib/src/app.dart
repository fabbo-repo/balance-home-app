import 'dart:io';

import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/navigation/router_provider.dart';
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
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      onGenerateTitle: (context) {
        // In the app build, the context does not contain an AppLocalizations instance.
        // However, at the moment the title is ggoing to be generated 
        // the AppLocalizations instance is not null
        return ref.read(appLocalizationsProvider).appTitle;
      },
      locale: ref.watch(localeStateNotifierProvider).locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
        debugPrint("[LANGUAGE] Proposing $locale");
        if (locale != null) {
          for (Locale supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              debugPrint("[LANGUAGE] Using $locale");
              return supportedLocale;
            }
          }
        }
        debugPrint("[LANGUAGE] Using default en_US");
        return const Locale("en", "US");
      },
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: router.backButtonDispatcher
    );
  }
}