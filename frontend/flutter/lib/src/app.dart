import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
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
        navigationRailTheme: const NavigationRailThemeData(
          selectedIconTheme: IconThemeData(color: Colors.white),
          unselectedIconTheme: IconThemeData(color: Colors.white54),
          backgroundColor: Color.fromARGB(255, 70, 70, 70)
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          backgroundColor: Color.fromARGB(255, 70, 70, 70)
        )
      ),
      onGenerateTitle: (context) {
        // In the app build, the context does not contain an AppLocalizations instance.
        // However, at the moment the title is ggoing to be generated 
        // the AppLocalizations instance is not null
        final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
        return appLocalizations.appTitle;
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: router.backButtonDispatcher
    );
  }
}