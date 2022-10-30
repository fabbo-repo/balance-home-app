import 'package:balance_home_app/src/core/views/error_view.dart';
import 'package:balance_home_app/src/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>(
  (ref) {
    final router = RouterNotifier(ref);
    return GoRouter(
      errorBuilder: (context, state) => ErrorView(location: state.location),
      navigatorKey: navigatorKey,
      debugLogDiagnostics: true,
      redirect: router.appGuard,
      refreshListenable: router,
      routes: router.routes,
    );
  }
);
