import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_field.dart';
import 'package:balance_home_app/src/features/login/data/models/credentials_model.dart';
import 'package:balance_home_app/src/features/login/logic/providers/login_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginView extends ConsumerStatefulWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginView({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {

  @override
  Widget build(BuildContext context) {
    final loginForm  = ref.watch(loginFormStateProvider).form;
    final loginFormState = ref.read(loginFormStateProvider.notifier);
    final loginState = ref.watch(loginStateNotifierProvider);
    final loginStateNotifier = ref.watch(loginStateNotifierProvider.notifier);
    final appLocalizations = ref.read(appLocalizationsProvider);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SimpleTextField(
              title: appLocalizations.emailAddress,
              controller: widget.emailController,
              onChanged: (email) {
                loginFormState.setEmail(email);
              },
              error: loginForm.email.errorMessage,
            ),
            PasswordTextField(
              title: appLocalizations.password,
              controller: widget.passwordController,
              onChanged: (password) {
                loginFormState.setPassword(password);
              },
              error: loginForm.password.errorMessage,
            ),
            Text(
              (loginState is AuthStateError) ?
              (loginState).error : "",
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
                enabled: loginForm.isValid
                  && loginState is! AuthStateLoading,
                onPressed: () async {
                  CredentialsModel credentials = loginForm.toModel();
                  await loginStateNotifier.updateJwtAndAccount(credentials);
                  if (loginState is AuthStateSuccess) {
                    // Context is not used if widget is not in the tree
                    if (!mounted) return;
                    context.go("/");
                  }
                }, 
                child: loginState is AuthStateLoading ?
                  const CircularProgressIndicator() : 
                  Text(appLocalizations.signIn)
              )
            ),
            TextButton(
              onPressed: () {  },
              child: Text(appLocalizations.forgotPassword),
            ),
          ],
        ),
      ),
    );
  }
}