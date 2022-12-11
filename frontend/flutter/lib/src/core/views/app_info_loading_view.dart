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
          final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
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
                          "${appLocalizations.version} "
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
                child: Text(errorMessage ?? appLocalizations.genericError),
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
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await ref.read(httpServiceProvider).sendGetRequest(APIContract.frontendVersion);
      if (isLowerVersion(packageInfo.version, response.content["version"])) {
        errorMessage = appLocalizations.wrongVersion;
        return false;
      }
      // Update Package Info State provider
      ref.read(packageInfoStateNotifierProvider.notifier).setPackageInfo(packageInfo);
    } catch (e) {
      errorMessage = appLocalizations.badRequest;
    }
    return true;
  }

  /// Checks if [version1] is lower than [version2]
  bool isLowerVersion(String version1, String version2) {
    List<int> versionIntList1 = version1.split(".").map((e) => int.parse(e)).toList();
    List<int> versionIntList2 = version2.split(".").map((e) => int.parse(e)).toList();
    if (versionIntList1[0] > versionIntList2[0]) {
      return false;
    } else if (versionIntList1[0] < versionIntList2[0]) {
      return true;
    } else { // versionIntList1[0] == versionIntList2[0]
      if (versionIntList1[1] > versionIntList2[1]) {
        return false;
      } else if (versionIntList1[1] < versionIntList2[1]) {
        return true;
      }else { // versionIntList1[1] == versionIntList2[1]
        if (versionIntList1[2] > versionIntList2[2]) {
          return false;
        } else if (versionIntList1[2] < versionIntList2[2]) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future<bool> oneSecond() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}