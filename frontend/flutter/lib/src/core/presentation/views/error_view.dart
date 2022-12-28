import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_error_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ErrorView extends ConsumerWidget {
  /// Named route for [ErrorView].
  static const String routeName = 'error';

  /// Path route for [ErrorView].
  static const String routePath = 'error';

  final String location;

  const ErrorView({
    required this.location,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return Scaffold(
      body: CustomErrorWidget(
        text: (location == '/$routePath') ? 
        appLocalizations.genericError
        : appLocalizations.pageNotFound,
      ),
    );
  }

  /// Redirects current view to [ErrorView].
  static void go() {
    navigatorKey.currentContext!
      .go('/$routePath');
  }
}