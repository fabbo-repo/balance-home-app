import 'package:balance_home_app/src/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends ConsumerWidget {
  final double? fontSize;

  const AppTitle({this.fontSize, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          appLocalizations.appTitle1,
          style: GoogleFonts.openSans(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: fontSize ?? 40,
              fontStyle: FontStyle.italic),
        ),
        Text(
          appLocalizations.appTitle2,
          style: GoogleFonts.openSans(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: fontSize ?? 40,
              fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
