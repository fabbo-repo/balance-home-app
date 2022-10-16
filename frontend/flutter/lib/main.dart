import 'package:balance_home_app/src/app.dart';
import 'package:balance_home_app/src/common/app_config/env_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  //usePathUrlStrategy();
  setPathUrlStrategy();

  // Env file should be loaded before Firebase initialization
  await EnvModel.loadEnvFile();
  
  runApp(
    const ProviderScope(
      child: BalanceHomeApp()
    )
  );
}
