import 'package:balance_home_app/src/features/auth/controllers/login_controller.dart';
import 'package:balance_home_app/src/features/auth/screens/auth_screen.dart';
import 'package:balance_home_app/src/features/auth/utils/login_states.dart';
import 'package:balance_home_app/src/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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