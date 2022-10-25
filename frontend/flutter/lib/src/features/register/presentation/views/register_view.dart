import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends ConsumerStatefulWidget {

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordController2 = TextEditingController();

  RegisterView({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {

  @override
  Widget build(BuildContext context) {
    //final registerFormStateNotifierProvider = ref.watch(registerFormStateProvider).form;
    //final registerFormStateProvider = ref.read(registerFormStateProvider.notifier);
    //final registerStateNotifierProvider = ref.watch(registerStateNotifierProvider);
    //final registerStateNotifier = ref.watch(loginStateNotifierProvider.notifier);
    final appLocalizations = ref.read(appLocalizationsProvider);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SimpleTextField(
              title: appLocalizations.username,
              controller: widget.usernameController,
              onChanged: (username) {
                //registerFormStateProvider.setUsername(username);
              },
              //error: registerFormStateNotifierProvider.username.errorMessage,
            ),
            SimpleTextField(
              title: appLocalizations.emailAddress,
              controller: widget.emailController,
              onChanged: (email) {
                //registerFormStateProvider.setEmail(email);
              },
              //error: registerFormStateNotifierProvider.email.errorMessage,
            ),
            PasswordTextField(
              title: appLocalizations.password,
              controller: widget.passwordController,
              onChanged: (password) {
                //registerFormStateProvider.setPassword(password);
              },
              //error: registerFormStateNotifierProvider.password.errorMessage,
            ),
            PasswordTextField(
              title: appLocalizations.repeatPassword,
              controller: widget.passwordController2,
              onChanged: (password2) {
                //registerFormStateProvider.setPassword2(password2);
              },
              //error: registerFormStateNotifierProvider.password2.errorMessage,
            ),
            Text(
              //(registerStateNotifierProvider is RegisterStateError) ?
              //(registerStateNotifierProvider).error : 
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
                enabled: true, //registerFormStateNotifierProvider.isValid
                  //&& !(registerStateNotifierProvider is RegisterStateLoading),
                onPressed: () async {
                  //RegisterModel registration = registerFormStateNotifierProvider.toModel();
                  //await registerStateNotifier.registerUser(registration);
                  //if (registerStateNotifierProvider is RegisterStateSuccess) {
                  //  // Retry login
                  //  context.go("/auth");
                  //}
                }, 
                child: //registerStateNotifierProvider is RegisterStateLoading ?
                  //CircularProgressIndicator() : 
                  Text(appLocalizations.register)
              )
            ),
          ],
        ),
      ),
    );
  }
}