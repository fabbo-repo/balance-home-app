import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_loading_widget.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthLoadingView extends ConsumerWidget {
  /// Named route for [AuthLoadingView]
  static const String routeName = 'authLoading';

  /// Path route for [AuthLoadingView]
  static const String routePath = 'auth-load';

  const AuthLoadingView({required this.location, super.key});

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    Future.delayed(Duration.zero, () async {
      final value = await authController.trySignIn();
      if (location == "/${AuthView.routePath}") {
        goLocation(extra: true);
        return const Scaffold(body: AppLoadingWidget());
      }
      value.fold((_) {
        AppErrorView.go404();
        return const Scaffold(body: AppLoadingWidget());
      }, (_) {
        if (location != "/$routePath") {
          goLocation();
          return const Scaffold(body: AppLoadingWidget());
        } else {
          AppErrorView.go404();
          return const Scaffold(body: AppLoadingWidget());
        }
      });
    });
    return const Scaffold(body: AppLoadingWidget());
  }

  @visibleForTesting
  void goLocation({Object? extra}) {
    router.go(location, extra: extra);
  }
}
