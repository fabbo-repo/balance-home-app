import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
    
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //final _loginFormStateNotifierProvider = ref.watch(loginFormStateProvider).form;
    //final _loginFormStateProvider = ref.read(loginFormStateProvider.notifier);
    //final _loginStateNotifierProvider = ref.watch(loginStateNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SimpleTextField(
              title: ref.read(appLocalizationsProvider).username,
              controller: emailController,
              onChanged: (email) {
                //_loginFormStateProvider.setEmail(email);
              },
              //error: _loginFormStateNotifierProvider.email.errorMessage,
            ),
            SimpleTextField(
              title: ref.read(appLocalizationsProvider).emailAddress,
              controller: emailController,
              onChanged: (email) {
                //_loginFormStateProvider.setEmail(email);
              },
              //error: _loginFormStateNotifierProvider.email.errorMessage,
            ),
            PasswordTextField(
              title: ref.read(appLocalizationsProvider).password,
              controller: passwordController,
              onChanged: (password) {
                //_loginFormStateProvider.setPassword(password);
              },
              //error: _loginFormStateNotifierProvider.password.errorMessage,
            ),
            PasswordTextField(
              title: ref.read(appLocalizationsProvider).repeatPassword,
              controller: passwordController,
              onChanged: (password) {
                //_loginFormStateProvider.setPassword(password);
              },
              //error: _loginFormStateNotifierProvider.password.errorMessage,
            ),
            Text(
              //(_loginStateNotifierProvider is LoginStateError) ?
              //(_loginStateNotifierProvider).error : 
              "",
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
                enabled: true, //_loginFormStateNotifierProvider.isValid
                  //&& !(_loginStateNotifierProvider is LoginStateLoading),
                onPressed: () async {
                  //CredentialsModel credentials = _loginFormStateNotifierProvider.toModel();
                  //await ref.read(loginStateNotifierProvider.notifier).updateJwtAndAccount(credentials);
                  //if (_loginStateNotifierProvider is LoginStateSuccess) {
                  //  context.go("/");
                  //}
                }, 
                child: //_loginStateNotifierProvider is LoginStateLoading ?
                  //CircularProgressIndicator() : 
                  Text(ref.read(appLocalizationsProvider).register)
              )
            ),
          ],
        ),
      ),
    );
  }
}