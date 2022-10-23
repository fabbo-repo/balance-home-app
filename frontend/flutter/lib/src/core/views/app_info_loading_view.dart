import 'dart:developer';

import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/providers/package_info_provider.dart';
import 'package:balance_home_app/src/core/services/api_contract.dart';
import 'package:balance_home_app/src/core/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppInfoLoadingView extends ConsumerWidget {
  
  const AppInfoLoadingView({
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read app version
    ref.read(packageInfoProvider.future).then((value) async {
      try{
        HttpResponse response = await ref.read(httpServiceProvider)
          .sendGetRequest(APIContract.frontendVersion);
        if (response.statusCode == 200) {
          if (response.content.containsKey("version") 
            && response.content["version"] == value.version) {
            context.goNamed("home", params: {
              "version": value.version
            });
          } else {
            _goError(context, ref.read(appLocalizationsProvider).wronVersion);
          }
        } else {
          _goError(context, ref.read(appLocalizationsProvider).badRequest);
        }
      } catch (e) {
        log(e.toString());
        _goError(context, ref.read(appLocalizationsProvider).noInternet);
      }
    });
    return Scaffold(
      body: Center(
        child: Container(
          width: 50,
          height: 50,
          child: CircularProgressIndicator.adaptive(
            valueColor:  AlwaysStoppedAnimation<Color>(Colors.green),
            strokeWidth: 6.0,
          ),
        ),
      ),
    );
  }

  void _goError(BuildContext context, String message) {
    context.go("/error", extra: message);
  }
}