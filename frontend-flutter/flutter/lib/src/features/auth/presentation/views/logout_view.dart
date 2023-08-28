import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LogoutView extends ConsumerWidget {
  /// Named route for [LogoutView]
  static const String routeName = 'logout';

  /// Path route for [LogoutView]
  static const String routePath = 'logout';

  const LogoutView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    Future.delayed(Duration.zero, () async {
      final value = await authController.signOut();
      value.fold((_) {
        AppErrorView.go();
      }, (_) {
        navigatorKey.currentContext!.goNamed(AuthView.routeName);
      });
    });
    return const Scaffold(body: LoadingWidget());
  }
}
