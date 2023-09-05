import 'dart:async';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/presentation/views/app_info_loading_view.dart';
import 'package:balance_home_app/src/core/presentation/views/fade_transition_view.dart';
import 'package:balance_home_app/src/features/account/presentation/views/account_delete_view.dart';
import 'package:balance_home_app/src/features/account/presentation/views/account_edit_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_loading_view.dart';
import 'package:balance_home_app/src/core/presentation/views/app_error_view.dart';
import 'package:balance_home_app/src/core/presentation/views/app_loading_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/logout_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/reset_password_view.dart';
import 'package:balance_home_app/src/features/settings/presentation/views/settings_view.dart';
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
        .contains("/${AppErrorView.noConnectionErrorPath}")) {
      return const AppErrorView(
          location: "/${AppErrorView.noConnectionErrorPath}");
    }
    if (state.error.toString().contains("/${AppErrorView.notFoundPath}")) {
      return const AppErrorView(location: "/${AppErrorView.notFoundPath}");
    }
    debugPrint(state.error.toString());
    return const AppErrorView(location: '/${AppErrorView.routePath}');
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
        builder: (_, __) => const AppLoadingView(),
        redirect: rootGuard,
        routes: [
          GoRoute(
            name: AuthLoadingView.routeName,
            path: AuthLoadingView.routePath,
            builder: (context, state) {
              return AuthLoadingView(
                  location: GoRouterState.of(context)
                              .uri
                              .queryParameters['path'] !=
                          null
                      ? GoRouterState.of(context).uri.queryParameters['path']!
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
            name: AccountEditView.routeName,
            path: AccountEditView.routePath,
            redirect: authGuardOrNone,
            builder: (context, state) => AccountEditView(),
          ),
          GoRoute(
            name: AccountDeleteView.routeName,
            path: AccountDeleteView.routePath,
            redirect: authGuardOrNone,
            builder: (context, state) => const AccountDeleteView(),
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
            pageBuilder: (context, state) => FadeTransitionView(
                key: _homeScaffoldKey,
                child: const HomeView(
                    selectedSection: HomeTab.statistics,
                    child: Center(child: StatisticsView()))),
          ),
          GoRoute(
              name: BalanceView.routeRevenueName,
              path: BalanceView.routeRevenuePath,
              redirect: authGuardOrNone,
              pageBuilder: (context, state) => FadeTransitionView(
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
                          id: int.parse(GoRouterState.of(context)
                              .uri
                              .queryParameters['id']!),
                          balanceTypeMode: BalanceTypeMode.revenue,
                        )),
              ]),
          GoRoute(
              name: BalanceView.routeExpenseName,
              path: BalanceView.routeExpensePath,
              redirect: authGuardOrNone,
              pageBuilder: (context, state) => FadeTransitionView(
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
                          id: int.parse(GoRouterState.of(context)
                              .uri
                              .queryParameters['id']!),
                          balanceTypeMode: BalanceTypeMode.expense,
                        )),
              ]),
          GoRoute(
            name: AppInfoLoadingView.routeName,
            path: AppInfoLoadingView.routePath,
            builder: (context, state) => const AppInfoLoadingView(),
          ),
          GoRoute(
            name: AppLoadingView.routeName,
            path: AppLoadingView.routePath,
            builder: (context, state) => const AppLoadingView(),
          ),
          GoRoute(
              name: 'passwordRoot',
              path: 'password',
              redirect: passwordGuard,
              builder: (_, __) => AppLoadingView(func: (context) {
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
  final goingToRoot = state.matchedLocation == '/';
  if (goingToRoot) {
    return "/${AppInfoLoadingView.routePath}";
  }
  return null;
}

Future<String?> logoutGuard(BuildContext context, GoRouterState state) async {
  final loggedIn = authStateListenable.value;
  final goingToLogout = state.matchedLocation == '/${LogoutView.routePath}';
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
          state.name == AccountDeleteView.routeName ||
          state.name == LogoutView.routeName)) {
    return "/${AppErrorView.noConnectionErrorPath}";
  }
  if (!loggedIn) {
    return "/${AuthLoadingView.routePath}?path=${state.matchedLocation}";
  }
  return null;
}

Future<String?> passwordGuard(BuildContext context, GoRouterState state) async {
  final isConnected = connectionStateListenable.value;
  if (!isConnected) {
    return "/${AppErrorView.noConnectionErrorPath}";
  }
  final goingToPassword = state.matchedLocation == '/password';
  if (goingToPassword) return "/";
  return null;
}
