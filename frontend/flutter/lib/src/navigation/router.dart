import 'dart:async';
import 'package:balance_home_app/src/core/views/app_info_loading_view.dart';
import 'package:balance_home_app/src/core/views/loading_view.dart';
import 'package:balance_home_app/src/features/auth/views/auth_view.dart';
import 'package:balance_home_app/src/features/home/views/home_view.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    /*_ref.listen<LoginState>(
      loginStateNotifierProvider, 
      (_, __) { notifyListeners(); }
    );*/
  }

  List<GoRoute> get routes => [
    GoRoute(
      name: 'home',
      path: '/',
      redirect: rootGuard,
      builder: (context, state) => const HomeView(),
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
      name: 'authentication',
      path: '/auth',
      redirect: authGuard,
      builder: (context, state) => const AuthView(),
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
    final loginState = _ref.read(loginStateNotifierProvider);
    if (loginState is AuthStateSuccess) return null;
    if (state.location == '/') return '/load-app-info';
    return null;
  }

  Future<String?> authGuard(BuildContext context, GoRouterState state) async {
    final loginState = _ref.read(loginStateNotifierProvider);
    final loginStateNotifier = _ref.read(loginStateNotifierProvider.notifier);
    // if trySilentLogin is succesfully executed it will set LoginState to LoginStateSuccess
    if (loginState is AuthStateInitial) await loginStateNotifier.trySilentLogin();
    if (_ref.read(loginStateNotifierProvider) is AuthStateSuccess) return '/';
    return null;
  }
}