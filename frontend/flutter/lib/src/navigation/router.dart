import 'dart:async';
import 'package:balance_home_app/src/core/presentation/views/app_info_loading_view.dart';
import 'package:balance_home_app/src/core/presentation/views/loading_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_tabs.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_view.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/login/presentation/views/forgot_password_view.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref ref;
  final ValueKey<String> _scaffoldKey =
      const ValueKey<String>('balhom_scaffold');

  RouterNotifier(this.ref);

  List<GoRoute> get routes => [
        GoRoute(name: 'root', path: '/', redirect: rootGuard),
        GoRoute(
          name: 'statistics',
          path: '/statistics',
          redirect: homeGuard,
          pageBuilder: (context, state) => FadeTransitionPage(
              key: _scaffoldKey,
              child: HomeView(
                  selectedSection: HomeTab.statistics,
                  child: Center(child: StatisticsView()))),
        ),
        GoRoute(
          name: 'revenues',
          path: '/revenues',
          redirect: homeGuard,
          pageBuilder: (context, state) => FadeTransitionPage(
              key: _scaffoldKey,
              child: HomeView(
                  selectedSection: HomeTab.revenues,
                  child: BalanceView(
                    balanceTypeMode: BalanceTypeMode.revenue,
                  ))),
        ),
        GoRoute(
          name: 'expenses',
          path: '/expenses',
          redirect: homeGuard,
          pageBuilder: (context, state) => FadeTransitionPage(
              key: _scaffoldKey,
              child: HomeView(
                  selectedSection: HomeTab.expenses,
                  child: BalanceView(
                    balanceTypeMode: BalanceTypeMode.expense,
                  ))),
        ),
        GoRoute(
          name: 'loadingAppInfo',
          path: '/load-app-info',
          builder: (context, state) => AppInfoLoadingView(),
        ),
        GoRoute(
          name: 'loading',
          path: '/load',
          builder: (context, state) => const LoadingView(),
        ),
        GoRoute(
          name: 'forgotPasswordReset',
          path: '/password/reset',
          builder: (context, state) => ForgotPasswordView(),
        ),
        GoRoute(
          name: 'authentication',
          path: '/auth',
          redirect: authGuard,
          builder: (context, state) => AuthView(),
        ),
      ];

  String? appGuard(BuildContext context, GoRouterState state) {
    return null;
  }

  String? errorGuard(BuildContext context, GoRouterState state) {
    if (state.extra == null) return '/';
    return null;
  }

  String? rootGuard(BuildContext context, GoRouterState state) {
    final loginState = ref.read(loginStateNotifierProvider);
    if (loginState is AuthStateSuccess) return "/statistics";
    if (state.location == '/') return '/load-app-info';
    return "/statistics";
  }

  Future<String?> authGuard(BuildContext context, GoRouterState state) async {
    final loginState = ref.read(loginStateNotifierProvider);
    final loginStateNotifier = ref.read(loginStateNotifierProvider.notifier);
    // if trySilentLogin is succesfully executed it will set LoginState to LoginStateSuccess
    if (loginState is AuthStateInitial)
      await loginStateNotifier.trySilentLogin();
    if (ref.read(loginStateNotifierProvider) is AuthStateSuccess) return '/';
    return null;
  }

  String? homeGuard(BuildContext context, GoRouterState state) {
    if (ref.read(loginStateNotifierProvider) is! AuthStateSuccess) return '/';
    return null;
  }
}

/// A page that fades in an out.
class FadeTransitionPage extends CustomTransitionPage<void> {
  /// Creates a [FadeTransitionPage].
  FadeTransitionPage({
    required LocalKey key,
    required Widget child,
  }) : super(
            key: key,
            transitionsBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) =>
                FadeTransition(
                  opacity: animation.drive(_curveTween),
                  child: child,
                ),
            child: child);

  static final CurveTween _curveTween = CurveTween(curve: Curves.easeIn);
}
