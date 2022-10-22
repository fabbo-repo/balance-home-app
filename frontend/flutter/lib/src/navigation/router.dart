import 'dart:async';
import 'dart:developer';

import 'package:balance_home_app/src/core/providers/package_info_provider.dart';
import 'package:balance_home_app/src/core/views/loading_view.dart';
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
      redirect: rootGuard,
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: 'loading',
      path: '/load-app-info',
      builder: (context, state) => LoadingView(
        func: (context) async {
          await Future.delayed(Duration(seconds: 5));
          context.go("/auth");
        }
      ),
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

  FutureOr<String?> rootGuard(BuildContext context, GoRouterState state) async {
    try {
      _ref.read(packageInfoProvider.future).then((value) {
        log(value.version);
      });
    } catch (e) {
      log(e.toString());
      notifyListeners();
    }
    log(state.location);
    if (state.location == '/') return '/load-app-info';
    return null;
  }

  FutureOr<String?> authGuard(BuildContext context, GoRouterState state) async {
    //if(_ref.read(packageInfoProvider).value != null)
    //  log("aaaaaa"+_ref.read(packageInfoProvider).value!.appName);
    final loginState = _ref.read(loginStateNotifierProvider);
    final isRoot = state.location == '/';
    if (loginState == LoginState.initial() && isRoot) {
      return '/auth';
    }
    if (isRoot) return '/';
    return null;
  }
}