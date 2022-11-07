import 'package:balance_home_app/src/navigation/router_provider.dart';
import 'package:go_router/go_router.dart';

class RequestErrorHandlerLibW {
  void goToErrorPage() {
    navigatorKey.currentContext!
      .go('/server-error');
  }
}