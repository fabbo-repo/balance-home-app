import 'dart:async';
import 'package:balance_home_app/src/core/presentation/views/app_info_loading_view.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/core/presentation/views/loading_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_create_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_tabs.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_view.dart';
import 'package:balance_home_app/src/features/login/presentation/views/forgot_password_view.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main router
///
/// ! Pay attention to the order of routes.
///
/// ! Note about parameters
/// Router keeps parameters in global map. It means that if you create route
/// organization/:id and organization/:id/department/:id. Department id will
///  override organization id. So use :oid and :did instead of :id
/// Also router does not provide option to set regex for parameters.
/// If you put - example/:eid before - example/create for route - example/create
/// will be called route - example/:eid
///
///
final router = GoRouter(
  errorBuilder: (context, state) => ErrorView(location: state.location),
  navigatorKey: navigatorKey,
  debugLogDiagnostics: true,
  refreshListenable: authStateListenable,
  redirect: appGuard,
  observers: [routeObserver],
  routes: [
    GoRoute(name: 'root', path: '/', redirect: rootGuard, routes: [
      GoRoute(
        name: StatisticsView.routeName,
        path: StatisticsView.routePath,
        redirect: authGuard,
        pageBuilder: (context, state) => FadeTransitionPage(
            key: _scaffoldKey,
            child: const HomeView(
                selectedSection: HomeTab.statistics,
                child: Center(child: StatisticsView()))),
      ),
      GoRoute(
          name: BalanceView.routeRevenueName,
          path: BalanceView.routeRevenuePath,
          redirect: authGuard,
          pageBuilder: (context, state) => FadeTransitionPage(
              key: _scaffoldKey,
              child: const HomeView(
                  selectedSection: HomeTab.revenues,
                  child: BalanceView(
                    balanceTypeMode: BalanceTypeMode.revenue,
                  ))),
          routes: [
            GoRoute(
                name: BalanceCreateView.routeName,
                path: BalanceCreateView.routePath,
                builder: (context, state) => const BalanceCreateView(
                      balanceTypeMode: BalanceTypeMode.revenue,
                    )),
          ]),
      GoRoute(
          name: BalanceView.routeExpenseName,
          path: BalanceView.routeExpensePath,
          redirect: authGuard,
          pageBuilder: (context, state) => FadeTransitionPage(
              key: _scaffoldKey,
              child: const HomeView(
                  selectedSection: HomeTab.expenses,
                  child: BalanceView(
                    balanceTypeMode: BalanceTypeMode.expense,
                  ))),
          routes: [
            GoRoute(
                name: BalanceCreateView.routeName,
                path: BalanceCreateView.routePath,
                builder: (context, state) => const BalanceCreateView(
                      balanceTypeMode: BalanceTypeMode.expense,
                    )),
          ]),
      GoRoute(
        name: AppInfoLoadingView.routeName,
        path: AppInfoLoadingView.routePath,
        builder: (context, state) => AppInfoLoadingView(),
      ),
      GoRoute(
        name: LoadingView.routeName,
        path: LoadingView.routePath,
        builder: (context, state) => const LoadingView(),
      ),
      GoRoute(path: 'password', routes: [
        GoRoute(
          name: 'forgotPasswordReset',
          path: 'reset',
          builder: (context, state) => ForgotPasswordView(),
        ),
      ]),
      GoRoute(
        name: AuthView.routeName,
        path: AuthView.routePath,
        redirect: authGuard,
        builder: (context, state) => AuthView(),
      ),
    ]),
  ],
);

final navigatorKey = GlobalKey<NavigatorState>();

const ValueKey<String> _scaffoldKey = ValueKey<String>('balhom_scaffold');

/// Route observer to use with RouteAware
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

@visibleForTesting
String? appGuard(BuildContext context, GoRouterState state) {
  return null;
}

@visibleForTesting
String? rootGuard(BuildContext context, GoRouterState state) {
  final loggedIn = authStateListenable.value;
  final goingToRoot = state.location == '/';
  if (!loggedIn && goingToRoot) {
    return "/${AppInfoLoadingView.routePath}";
  } else if (loggedIn && goingToRoot) {
    return "/${AuthView.routePath}";
  }
  return null;
}

Future<String?> authGuard(BuildContext context, GoRouterState state) async {
  final loggedIn = authStateListenable.value;
  if (loggedIn) return '/';
  return null;
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
