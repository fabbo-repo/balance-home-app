import 'package:balance_home_app/common/widgets/text_fields/password_text_field.dart';
import 'package:balance_home_app/common/widgets/text_fields/simple_text_field.dart';
import 'package:balance_home_app/ui/auth/controllers/login_controller.dart';
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
              title: 'Email Address',
              textFieldController: emailController
            ),
            PasswordTextField(
              title: 'Password',
              textFieldController: passwordController
            ),
            Container(
              height: 50,
              width: 300,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                child: const Text('Login'),
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
              child: const Text( 'Forgot Password'),
            ),
          ],
        ),
      ),
    );
  }
}