import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/settings_widget.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class SettingsView extends ConsumerWidget {
  /// Route name
  static const routeName = 'settings';

  /// Route path
  static const routePath = 'settings';

  Widget cache = Container();

  SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    return user.when(data: (data) {
      cache = Scaffold(
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
              child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      ref.watch(themeModeProvider) == ThemeMode.dark
                          ? "assets/images/auth_background_dark_image.jpg"
                          : "assets/images/auth_background_image.jpg"),
                  fit: BoxFit.cover),
            ),
            constraints: const BoxConstraints.expand(),
            child: SettingsWidget(user: data!),
          )));
      return cache;
    }, error: (o, st) {
      return showError(o, st, cache: cache);
    }, loading: () {
      return showLoading(cache: cache);
    });
  }
}
