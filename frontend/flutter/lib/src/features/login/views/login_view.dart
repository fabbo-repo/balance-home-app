import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/common/widgets/text_fields/password_text_field.dart';
import 'package:balance_home_app/src/common/widgets/text_fields/simple_text_field.dart';
import 'package:balance_home_app/src/features/auth/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  
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
              controller: emailController
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
                onPressed: () {
                  ref
                    .read(loginControllerProvider.notifier)
                    .login(emailController.text, passwordController.text);
                },
              )
            ),
            TextButton(
              onPressed: () {
                //forgot password screen
              },
              child: Text(ref.read(appLocalizationsProvider).forgotPassword),
            ),
          ],
        ),
      ),
    );
  }
}