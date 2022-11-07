import 'package:balance_home_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  //usePathUrlStrategy();
  setPathUrlStrategy();

  runApp(
    const ProviderScope(
      child: BalanceHomeApp()
    )
  );
}