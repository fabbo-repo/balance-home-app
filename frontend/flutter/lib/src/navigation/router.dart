import 'package:balance_home_app/src/features/auth/views/auth_view.dart';
import 'package:balance_home_app/src/features/home/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    //_ref.listen<LoginState>(
    //  loginControllerProvider, 
    //  (_, __) { notifyListeners(); }
    //);
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

  String? redirectLogic(BuildContext context, GoRouterState state) {
    //final loginState = _ref.read(loginControllerProvider);
    final isLoggedIn = state.location == '/';
    //if (loginState is LoginStateInitial) {
    //  return isLoggedIn ? null : '/auth';
    //}
    if (isLoggedIn) return '/auth';

    return null;
  }
}