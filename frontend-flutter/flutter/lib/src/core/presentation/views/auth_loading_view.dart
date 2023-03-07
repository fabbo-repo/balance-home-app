import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    authController.trySignIn().then((value) {
      value.fold((l) {
        ErrorView.go404();
      }, (r) {
        if (location != "/$routePath") {
          navigatorKey.currentContext!.go(location);
        } else {
          ErrorView.go404();
        }
      });
    });
    return const Scaffold(body: LoadingWidget());
  }
}
