import 'package:balance_home_app/common/app_config/env_model.dart';
import 'package:balance_home_app/navigation/router_provider.dart';
import 'package:balance_home_app/providers/localization_providers/localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  //usePathUrlStrategy();
  setPathUrlStrategy();

  // Env file should be loaded before Firebase initialization
  await EnvModel.loadEnvFile();
  
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: router.backButtonDispatcher
    );
  }
}
