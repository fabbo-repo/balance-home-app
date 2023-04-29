import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class AppInfoLoadingView extends ConsumerWidget {
  /// Named route for [AuthView]
  static const String routeName = 'appInfoLoadingView';

  /// Path route for [AuthView]
  static const String routePath = 'app-info';

  String? errorMessage;

  AppInfoLoadingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return Scaffold(
        body: ref.watch(appVersionController).when<Widget>(
            data: (AppVersion? appVersion) {
      if (appVersion != null &&
          appVersion.isLower != null &&
          !appVersion.isLower!) {
        context.go("/${AuthView.routePath}");
        return LoadingWidget(
          color: Colors.green,
          text: "${appLocalizations.version} "
              "${appVersion.x}.${appVersion.y}.${appVersion.z}",
        );
      }
      if (appVersion != null &&
          ((appVersion.isLower != null && appVersion.isLower!) ||
              appVersion.isLower == null)) {
        return const LoadingWidget(color: Colors.grey);
      }
      return AppErrorWidget(
        color: Colors.red,
        text: appLocalizations.wrongVersion,
      );
    }, error: (Object o, StackTrace st) {
      return showError(o, st);
    }, loading: () {
      return showLoading();
    }));
  }
}
