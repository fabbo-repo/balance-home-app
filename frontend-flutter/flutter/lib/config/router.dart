import 'dart:async';
import 'package:balance_home_app/config/api_client.dart';
import 'package:balance_home_app/src/core/presentation/views/app_info_loading_view.dart';
import 'package:balance_home_app/src/core/presentation/views/auth_loading_view.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/core/presentation/views/loading_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/logout_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/reset_password_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/settings_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/user_delete_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/user_edit_view.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_create_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_edit_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_tabs.dart';
import 'package:balance_home_app/src/features/home/presentation/views/home_view.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  errorBuilder: (context, state) {
    if (state.error
        .toString()
        .contains("/${ErrorView.noConnectionErrorPath}")) {
      return const ErrorView(location: "/${ErrorView.noConnectionErrorPath}");
    }
    if (state.error.toString().contains("/${ErrorView.notFoundPath}")) {
      return const ErrorView(location: "/${ErrorView.notFoundPath}");
    }
    debugPrint(state.error.toString());
    return const ErrorView(location: '/${ErrorView.routePath}');
  },
  navigatorKey: navigatorKey,
  debugLogDiagnostics: true,
  refreshListenable: authStateListenable,
  redirect: appGuard,
  observers: [routeObserver],
  routes: [
    GoRoute(
        name: 'root',
        path: '/',
        builder: (_, __) => const LoadingView(),
        redirect: rootGuard,
        routes: [
          GoRoute(
            name: AuthLoadingView.routeName,
            path: AuthLoadingView.routePath,
            builder: (context, state) {
              return AuthLoadingView(
                  location: state.queryParameters['path'] != null
                      ? state.queryParameters['path']!
                      : "/${AuthLoadingView.routePath}");
            },
          ),
          GoRoute(
            name: AuthView.routeName,
            path: AuthView.routePath,
            redirect: authGuard,
            builder: (context, state) => AuthView(),
          ),
          GoRoute(
            name: LogoutView.routeName,
            path: LogoutView.routePath,
            redirect: logoutGuard,
            builder: (context, state) => const LogoutView(),
          ),
          GoRoute(
            name: UserEditView.routeName,
            path: UserEditView.routePath,
            redirect: authGuardOrNone,
            builder: (context, state) => UserEditView(),
          ),
          GoRoute(
            name: UserDeleteView.routeName,
            path: UserDeleteView.routePath,
            redirect: authGuardOrNone,
            builder: (context, state) => const UserDeleteView(),
          ),
          GoRoute(
            name: SettingsView.routeName,
            path: SettingsView.routePath,
            redirect: authGuardOrNone,
            builder: (context, state) => SettingsView(),
          ),
          GoRoute(
            name: StatisticsView.routeName,
            path: StatisticsView.routePath,
            redirect: authGuardOrNone,
            pageBuilder: (context, state) => FadeTransitionPage(
                key: _homeScaffoldKey,
                child: const HomeView(
                    selectedSection: HomeTab.statistics,
                    child: Center(child: StatisticsView()))),
          ),
          GoRoute(
              name: BalanceView.routeRevenueName,
              path: BalanceView.routeRevenuePath,
              redirect: authGuardOrNone,
              pageBuilder: (context, state) => FadeTransitionPage(
                  key: _homeScaffoldKey,
                  child: HomeView(
                      selectedSection: HomeTab.revenues,
                      child: BalanceView(
                        balanceTypeMode: BalanceTypeMode.revenue,
                      ))),
              routes: [
                GoRoute(
                    name: BalanceView.routeRevenueName +
                        BalanceCreateView.routeName,
                    path: BalanceCreateView.routePath,
                    builder: (context, state) => const BalanceCreateView(
                          balanceTypeMode: BalanceTypeMode.revenue,
                        )),
                GoRoute(
                    name: BalanceView.routeRevenueName +
                        BalanceEditView.routeName,
                    path: BalanceEditView.routePath,
                    builder: (context, state) => BalanceEditView(
                          id: int.parse(state.queryParameters['id']!),
                          balanceTypeMode: BalanceTypeMode.revenue,
                        )),
              ]),
          GoRoute(
              name: BalanceView.routeExpenseName,
              path: BalanceView.routeExpensePath,
              redirect: authGuardOrNone,
              pageBuilder: (context, state) => FadeTransitionPage(
                  key: _homeScaffoldKey,
                  child: HomeView(
                      selectedSection: HomeTab.expenses,
                      child: BalanceView(
                        balanceTypeMode: BalanceTypeMode.expense,
                      ))),
              routes: [
                GoRoute(
                    name: BalanceView.routeExpenseName +
                        BalanceCreateView.routeName,
                    path: BalanceCreateView.routePath,
                    builder: (context, state) => const BalanceCreateView(
                          balanceTypeMode: BalanceTypeMode.expense,
                        )),
                GoRoute(
                    name: BalanceView.routeExpenseName +
                        BalanceEditView.routeName,
                    path: BalanceEditView.routePath,
                    builder: (context, state) => BalanceEditView(
                          id: int.parse(state.queryParameters['id']!),
                          balanceTypeMode: BalanceTypeMode.expense,
                        )),
              ]),
          GoRoute(
            name: AppInfoLoadingView.routeName,
            path: AppInfoLoadingView.routePath,
            builder: (context, state) => const AppInfoLoadingView(),
          ),
          GoRoute(
            name: LoadingView.routeName,
            path: LoadingView.routePath,
            builder: (context, state) => const LoadingView(),
          ),
          GoRoute(
              name: 'passwordRoot',
              path: 'password',
              redirect: passwordGuard,
              builder: (_, __) => LoadingView(func: (context) {
                    context.go("/${AuthView.routePath}");
                  }),
              routes: [
                GoRoute(
                  name: ResetPasswordView.routeName,
                  path: ResetPasswordView.routePath,
                  builder: (context, state) => ResetPasswordView(),
                ),
              ]),
        ]),
  ],
);

final navigatorKey = GlobalKey<NavigatorState>();

const ValueKey<String> _homeScaffoldKey = ValueKey<String>('balhom_home');

/// Route observer to use with RouteAware
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

@visibleForTesting
String? appGuard(BuildContext context, GoRouterState state) {
  return null;
}

@visibleForTesting
String? rootGuard(BuildContext context, GoRouterState state) {
  final goingToRoot = state.location == '/';
  if (goingToRoot) {
    return "/${AppInfoLoadingView.routePath}";
  }
  return null;
}

Future<String?> logoutGuard(BuildContext context, GoRouterState state) async {
  final loggedIn = authStateListenable.value;
  final goingToLogout = state.location == '/${LogoutView.routePath}';
  if (!loggedIn && goingToLogout) {
    return "/";
  }
  return null;
}

Future<String?> authGuard(BuildContext context, GoRouterState state) async {
  final loggedIn = authStateListenable.value;
  final goingToAuth = state.name == AuthView.routeName;
  if (loggedIn && goingToAuth) {
    return "/${StatisticsView.routePath}";
  } else if (!loggedIn && !goingToAuth) {
    return '/';
  } else if (state.extra == null || state.extra != true) {
    return "/${AuthLoadingView.routePath}?path=/${AuthView.routePath}";
  }
  return null;
}

Future<String?> authGuardOrNone(
    BuildContext context, GoRouterState state) async {
  final loggedIn = authStateListenable.value;
  final isConnected = connectionStateListenable.value;
  if (!isConnected &&
      (state.name == SettingsView.routeName ||
          state.name == BalanceCreateView.routeName ||
          state.name == UserDeleteView.routeName ||
          state.name == LogoutView.routeName)) {
    return "/${ErrorView.noConnectionErrorPath}";
  }
  if (!loggedIn) {
    return "/${AuthLoadingView.routePath}?path=${state.location}";
  }
  return null;
}

Future<String?> passwordGuard(BuildContext context, GoRouterState state) async {
  final isConnected = connectionStateListenable.value;
  if (!isConnected) {
    return "/${ErrorView.noConnectionErrorPath}";
  }
  final goingToPassword = state.location == '/password';
  if (goingToPassword) return "/";
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
