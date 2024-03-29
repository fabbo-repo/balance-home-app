import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/presentation/views/background_view.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/settings_widget.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsView extends ConsumerWidget {
  /// Route name
  static const routeName = 'settings';

  /// Route path
  static const routePath = 'settings';
  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return user.when(data: (data) {
      cache.value = Scaffold(
          appBar: AppBar(
            title: const AppTittle(fontSize: 30),
            backgroundColor: AppColors.appBarBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => navigatorKey.currentContext!
                  .goNamed(StatisticsView.routeName),
            ),
          ),
          body: SafeArea(
              child: BackgroundWidget(
            child: SettingsWidget(user: data!),
          )));
      return cache.value;
    }, error: (error, st) {
      return showError(
          error: error,
          background: cache.value,
          text: appLocalizations.genericError);
    }, loading: () {
      return showLoading(background: cache.value);
    });
  }
}
