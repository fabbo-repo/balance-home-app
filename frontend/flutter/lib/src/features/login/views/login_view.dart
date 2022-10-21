import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_field.dart';
import 'package:balance_home_app/src/features/login/controllers/login_controller.dart';
import 'package:balance_home_app/src/features/login/providers/login_form_provider.dart';
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
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                return SimpleTextField(
                  title: ref.read(appLocalizationsProvider).emailAddress,
                  controller: emailController,
                  onChanged: (email) {
                    ref.read(loginFormProvider.notifier).setEmail(email);
                  },
                  error: ref.watch(loginFormProvider).form.email.errorMessage,
                );
              }
            ),
            PasswordTextField(
              title: ref.read(appLocalizationsProvider).password,
              controller: passwordController
            ),
            Container(
              height: 100,
              width: 300,
              padding: const EdgeInsets.fromLTRB(10, 35, 10, 15),
              child: ElevatedButton(
                child: Text(ref.read(appLocalizationsProvider).signIn),
              onPressed: (ref.watch(loginFormProvider).form.isValid) ? 
                null : 
                () {
                  //ref
                  //  .read(loginControllerProvider.notifier)
                  //  .login(emailController.text, passwordController.text);
                },
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