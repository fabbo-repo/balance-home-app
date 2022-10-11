import 'dart:developer';

import 'package:balance_home_app/providers/auth_providers/states/login_state.dart';
import 'package:balance_home_app/ui/auth/controllers/login_controller.dart';
import 'package:balance_home_app/ui/auth/screens/login_screen.dart';
import 'package:balance_home_app/ui/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final router = RouterNotifier(ref);
    return GoRouter(
      debugLogDiagnostics: true,
      refreshListenable: router,
      redirect: router._redirectLogic,
      routes: router._routes,
    );
  }
);

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<LoginState>(
      loginControllerProvider, 
      (_, __) {
        notifyListeners();
      }
    );
  }

  String? _redirectLogic(BuildContext context, GoRouterState state) {
    log(state.location);
    log(state.fullpath ?? "AAAAAAAAAAA");
    final loginState = _ref.read(loginControllerProvider);

    final isLoggedIn = state.location == '/login';

    if (loginState is LoginStateInitial) {
      return isLoggedIn ? null : '/login';
    }

    if (isLoggedIn) return '/';

    return null;
  }

  List<GoRoute> get _routes => [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
  ];
}