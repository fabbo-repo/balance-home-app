import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/providers/package_info_provider.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ignore: must_be_immutable
class AppInfoLoadingView extends ConsumerWidget {
  String? errorMessage;
  
  AppInfoLoadingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: isLastVersion(ref),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children;
          if (snapshot.hasData && snapshot.data!) {
            children = [
              FutureBuilder<bool>(
                future: oneSecond(),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) context.go("/auth");
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget> [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "${ref.read(appLocalizationsProvider).version} "
                          "${ref.read(packageInfoStateNotifierProvider.notifier).getPackageInfo()!.version}"
                        ),
                      ),
                    ]
                  );
                }
              ),
            ];
          } else if (snapshot.hasError || (snapshot.hasData && !snapshot.data!)) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(errorMessage ?? ref.read(appLocalizationsProvider).genericError),
              ),
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator.adaptive(
                  valueColor:  AlwaysStoppedAnimation<Color>(Colors.green),
                  strokeWidth: 6.0,
                ),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }

  Future<bool> isLastVersion(WidgetRef ref) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await ref.read(httpServiceProvider).sendGetRequest(APIContract.frontendVersion);
      if (response.content["version"] != packageInfo.version) {
        errorMessage = ref.read(appLocalizationsProvider).wrongVersion;
        return false;
      }
      // Update Package Info State provider
      ref.read(packageInfoStateNotifierProvider.notifier).setPackageInfo(packageInfo);
    } catch (e) {
      errorMessage = ref.read(appLocalizationsProvider).badRequest;
    }
    return true;
  }

  Future<bool> oneSecond() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}