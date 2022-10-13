import 'package:balance_home_app/common/widgets/text_fields/password_text_field.dart';
import 'package:balance_home_app/common/widgets/text_fields/simple_text_field.dart';
import 'package:balance_home_app/providers/localization_providers/localization_provider.dart';
import 'package:balance_home_app/ui/auth/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  
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
              textFieldController: emailController
            ),
            PasswordTextField(
              title: ref.read(appLocalizationsProvider).password,
              textFieldController: passwordController
            ),
            Container(
              height: 50,
              width: 300,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                child: Text(ref.read(appLocalizationsProvider).login),
                onPressed: () {
                  ref.read(loginControllerProvider.notifier)
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