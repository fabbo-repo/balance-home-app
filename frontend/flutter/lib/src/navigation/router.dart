import 'package:balance_home_app/src/features/auth/views/auth_view.dart';
import 'package:balance_home_app/src/features/home/views/home_view.dart';
import 'package:balance_home_app/src/features/login/logic/login_state.dart';
import 'package:balance_home_app/src/features/login/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<LoginState>(
      loginStateNotifierProvider, 
      (_, __) { notifyListeners(); }
    );
  }

  List<GoRoute> get routes => [
    GoRoute(
      name: 'home',
      path: '/',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: 'auth',
      path: '/auth',
      builder: (context, state) => const AuthView(),
    ),
  ];

  String? authenticationGuard(BuildContext context, GoRouterState state) {
    final loginState = _ref.read(loginStateNotifierProvider);
    final isRoot = state.location == '/';
    if (loginState == LoginState.initial() && isRoot) {
      return '/auth';
    }
    if (isRoot) return '/';
    return null;
  }
}