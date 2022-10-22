import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_field.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/logic/login_state.dart';
import 'package:balance_home_app/src/features/login/providers/login_form_provider.dart';
import 'package:balance_home_app/src/features/login/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SimpleTextField(
              title: ref.read(appLocalizationsProvider).emailAddress,
              controller: emailController,
              onChanged: (email) {
                ref.read(loginFormProvider.notifier).setEmail(email);
              },
              error: ref.watch(loginFormProvider).form.email.errorMessage,
            ),
            PasswordTextField(
              title: ref.read(appLocalizationsProvider).password,
              controller: passwordController,
              onChanged: (password) {
                ref.read(loginFormProvider.notifier).setPassword(password);
              },
              error: ref.watch(loginFormProvider).form.password.errorMessage,
            ),
            Container(
              height: 100,
              width: 300,
              padding: const EdgeInsets.fromLTRB(10, 35, 10, 15),
              child:  SimpleTextButton(
                enabled: ref.watch(loginFormProvider).form.isValid
                  && ref.watch(loginStateNotifierProvider) != LoginState.loading(),
                onPressed: () async {
                  CredentialsModel credentials = ref.read(loginFormProvider).form.toModel();
                  ref.read(loginStateNotifierProvider.notifier).getJwt(credentials);
                }, 
                child: (ref.watch(loginStateNotifierProvider) == LoginState.loading()) ?
                  CircularProgressIndicator() : 
                  Text(ref.read(appLocalizationsProvider).signIn)
              )
            ),
            TextButton(
              onPressed: () {  },
              child: Text(ref.read(appLocalizationsProvider).forgotPassword),
            ),
          ],
        ),
      ),
    );
  }
}