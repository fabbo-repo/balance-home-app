import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/logic/login_state.dart';
import 'package:balance_home_app/src/features/login/providers/login_form_provider.dart';
import 'package:balance_home_app/src/features/login/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginButton extends ConsumerWidget {
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginStateNotifierProvider);
    return ElevatedButton(
      onPressed: () async {
        CredentialsModel credentials = ref.read(loginFormProvider).form.toModel();
        ref.read(loginStateNotifierProvider.notifier).getJwt(credentials);
      }, 
      child: (state == LoginState.loading()) ?
        CircularProgressIndicator() : 
        Text(ref.read(appLocalizationsProvider).signIn)
    );
  }
}
