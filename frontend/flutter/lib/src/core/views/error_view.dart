import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorView extends ConsumerWidget {
  final String location;

  const ErrorView({
    required this.location,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: (location == '/server-error') ? 
        Text(ref.read(appLocalizationsProvider).genericError)
        : Text(ref.read(appLocalizationsProvider).pageNotFound),
      ),
    );
  }
}