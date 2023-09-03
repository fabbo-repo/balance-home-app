import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppInfoLoadingView extends ConsumerStatefulWidget {
  /// Named route for [AuthView]
  static const String routeName = 'appInfoLoadingView';

  /// Path route for [AuthView]
  static const String routePath = 'app-info';

  const AppInfoLoadingView({super.key});

  @override
  ConsumerState<AppInfoLoadingView> createState() => _AppInfoLoadingViewState();
}

class _AppInfoLoadingViewState extends ConsumerState<AppInfoLoadingView> {
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return Scaffold(
        body: ref.watch(appVersionController).when<Widget>(
            data: (final failureOrAppVersion) {
      return failureOrAppVersion.fold((failure) {
        if (failure is HttpConnectionFailure) {
          Future.delayed(Duration.zero, () {
            router.goNamed(AuthView.routeName);
          });
          return showError(
              icon: Icons.network_wifi_1_bar,
              text: appLocalizations.noConnection);
        }
        return showError(
            icon: Icons.network_wifi_1_bar,
            text: appLocalizations.genericError);
      }, (appVersion) {
        if (appVersion.isLower != null && !appVersion.isLower!) {
          Future.delayed(Duration.zero, () {
            router.goNamed(AuthView.routeName);
          });
          return AppLoadingWidget(
            color: Colors.green,
            text: "${appLocalizations.version} "
                "${appVersion.x}.${appVersion.y}.${appVersion.z}",
          );
        }
        return showError(
            icon: Icons.network_wifi_1_bar,
            text: appLocalizations.wrongVersion);
      });
    }, error: (error, _) {
      return showError(error: error, text: appLocalizations.genericError);
    }, loading: () {
      return showLoading();
    }));
  }
}
