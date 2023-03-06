import 'dart:async';
import 'dart:convert';
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
  errorBuilder: (context, state) {
    if (state.error.toString().contains("no routes")) {
      return ErrorView(location: state.location);
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
              Codec<String, String> stringToBase64 = utf8.fuse(base64Url);
              return AuthLoadingView(
                  location: state.queryParams['path'] != null
                      ? stringToBase64.decode(state.queryParams['path']!)
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
            redirect: authGuard,
            builder: (context, state) => const LogoutView(),
          ),
          GoRoute(
            name: UserEditView.routeName,
            path: UserEditView.routePath,
            redirect: authGuardOrNone,
            builder: (context, state) => const UserEditView(),
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
                key: _scaffoldKey,
                child: const HomeView(
                    selectedSection: HomeTab.statistics,
                    child: Center(child: StatisticsView()))),
          ),
          GoRoute(
              name: BalanceView.routeRevenueName,
              path: BalanceView.routeRevenuePath,
              redirect: authGuardOrNone,
              pageBuilder: (context, state) => FadeTransitionPage(
                  key: _scaffoldKey,
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
                      id: int.parse(state.queryParams['id']!),
                          balanceTypeMode: BalanceTypeMode.revenue,
                        )),
              ]),
          GoRoute(
              name: BalanceView.routeExpenseName,
              path: BalanceView.routeExpensePath,
              redirect: authGuardOrNone,
              pageBuilder: (context, state) => FadeTransitionPage(
                  key: _scaffoldKey,
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
                      id: int.parse(state.queryParams['id']!),
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
  final goingToRoot = state.location == '/';
  if (goingToRoot) {
    return "/${AppInfoLoadingView.routePath}";
  }
  return null;
}

Future<String?> authGuard(BuildContext context, GoRouterState state) async {
  final loggedIn = authStateListenable.value;
  final goingToAuth = state.location == '/${AuthView.routePath}';
  if (!loggedIn && goingToAuth) return null;
  if (loggedIn && goingToAuth) return "/${StatisticsView.routePath}";
  if (!loggedIn) return '/';
  return null;
}

Future<String?> authGuardOrNone(
    BuildContext context, GoRouterState state) async {
  final loggedIn = authStateListenable.value;
  if (!loggedIn) {
    Codec<String, String> stringToBase64 =
        utf8.fuse(const Base64Codec.urlSafe());
    return "/${AuthLoadingView.routePath}?path=${stringToBase64.encode(state.location)}";
  }
  return null;
}

Future<String?> passwordGuard(BuildContext context, GoRouterState state) async {
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
