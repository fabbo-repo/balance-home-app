import 'package:balance_home_app/providers/auth_providers/states/login_state.dart';
import 'package:balance_home_app/ui/auth/controllers/login_controller.dart';
import 'package:balance_home_app/ui/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/auth/screens/auth_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<LoginState>(
      loginControllerProvider, 
      (_, __) { notifyListeners(); }
    );
  }

  List<GoRoute> get routes => [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
  ];

  String? redirectLogic(BuildContext context, GoRouterState state) {
    final loginState = _ref.read(loginControllerProvider);
    final isLoggedIn = state.location == '/login';
    if (loginState is LoginStateInitial) {
      return isLoggedIn ? null : '/login';
    }
    if (isLoggedIn) return '/';
    return null;
  }
}