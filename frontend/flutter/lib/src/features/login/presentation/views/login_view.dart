import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_field.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_provider.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final _loginFormStateNotifierProvider = ref.watch(loginFormStateProvider).form;
    final _loginFormStateProvider = ref.read(loginFormStateProvider.notifier);
    final _loginStateNotifierProvider = ref.watch(loginStateNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SimpleTextField(
              title: ref.read(appLocalizationsProvider).emailAddress,
              controller: emailController,
              onChanged: (email) {
                _loginFormStateProvider.setEmail(email);
              },
              error: _loginFormStateNotifierProvider.email.errorMessage,
            ),
            PasswordTextField(
              title: ref.read(appLocalizationsProvider).password,
              controller: passwordController,
              onChanged: (password) {
                _loginFormStateProvider.setPassword(password);
              },
              error: _loginFormStateNotifierProvider.password.errorMessage,
            ),
            Text(
              (_loginStateNotifierProvider is LoginStateError) ?
              (_loginStateNotifierProvider).error : "",
              style: const TextStyle(
                color: Colors.red, 
                fontSize: 14
              ),
            ),
            Container(
              height: 100,
              width: 300,
              padding: const EdgeInsets.fromLTRB(10, 35, 10, 15),
              child:  SimpleTextButton(
                enabled: _loginFormStateNotifierProvider.isValid
                  && !(_loginStateNotifierProvider is LoginStateLoading),
                onPressed: () async {
                  CredentialsModel credentials = _loginFormStateNotifierProvider.toModel();
                  await ref.read(loginStateNotifierProvider.notifier).updateJwtAndAccount(credentials);
                  if (_loginStateNotifierProvider is LoginStateSuccess) {
                    context.go("/");
                  }
                }, 
                child: _loginStateNotifierProvider is LoginStateLoading ?
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