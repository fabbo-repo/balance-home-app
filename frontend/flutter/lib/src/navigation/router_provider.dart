import 'package:balance_home_app/src/navigation/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final router = RouterNotifier(ref);
    return GoRouter(
      debugLogDiagnostics: true,
      refreshListenable: router,
      redirect: router.authenticationGuard,
      routes: router.routes,
    );
  }
);
