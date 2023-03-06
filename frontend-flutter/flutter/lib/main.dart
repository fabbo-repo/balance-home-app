import 'package:balance_home_app/src/app.dart';
import 'package:balance_home_app/src/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  runApp(
    UncontrolledProviderScope(
      container: await bootstrap(),
      child: const BalanceHomeApp()
    )
  );
}