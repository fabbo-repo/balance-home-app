import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTittle extends ConsumerWidget {
  final double? fontSize;

  const AppTittle({this.fontSize, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          appLocalizations.appTitle1,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? 40,
            fontStyle: FontStyle.italic
          ),
        ),
        Text(
          appLocalizations.appTitle2,
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: fontSize ?? 40,
            fontStyle: FontStyle.italic
          ),
        ),
      ],
    );
  }
}