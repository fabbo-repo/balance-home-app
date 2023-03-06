import 'package:balance_home_app/src/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackgroundWidget extends ConsumerWidget {
  final Widget child;

  const BackgroundWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ref.watch(themeModeProvider) == ThemeMode.dark
                  ? "assets/images/auth_background_dark_image.jpg"
                  : "assets/images/auth_background_image.jpg"),
              fit: BoxFit.cover),
        ),
        constraints: const BoxConstraints.expand(),
        child: child);
  }
}
