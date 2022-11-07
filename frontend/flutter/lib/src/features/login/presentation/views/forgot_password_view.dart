import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/views/app_titlle.dart';
import 'package:balance_home_app/src/core/widgets/language_picker_dropdown.dart';
import 'package:balance_home_app/src/core/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_field.dart';
import 'package:balance_home_app/src/features/login/logic/providers/forgot_password/forgot_password_provider.dart';
import 'package:balance_home_app/src/features/login/logic/providers/forgot_password/forgot_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:language_picker/languages.dart';

class ForgotPasswordView extends ConsumerWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final codeController = TextEditingController();

  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    final forgotPasswordForm = ref.watch(forgotPasswordFormStateProvider).form;
    final forgotPasswordFormState = ref.read(forgotPasswordFormStateProvider.notifier);
    final forgotPasswordState = ref.watch(forgotPasswordStateNotifierProvider);
    final forgotPasswordStateNotifier = ref.watch(forgotPasswordStateNotifierProvider.notifier);
    final localizationStateNotifier = ref.read(localizationStateNotifierProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/auth_background_image.jpg"),
              fit: BoxFit.cover
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [                  
                  Align(
                    alignment: Alignment.topLeft,
                    child: ElevatedButton(
                      onPressed: () { 
                        try {
                          context.pop();
                        } catch (e) {
                          context.go("/");
                        }
                      },
                      child: const Icon(Icons.arrow_circle_left_outlined),
                    ),
                  ),
                  // Space between buttons:
                  Expanded(child: Container(),),
                  Align(
                    alignment: Alignment.topRight,
                    child: CustomLanguagePickerDropdown(
                      appLocalizations: appLocalizations,
                      onValuePicked: (Language language) {
                        Locale locale = Locale(language.isoCode);
                        localizationStateNotifier.setLocalization(locale);
                      }
                    ),
                  ),
                ],
              ),
              if (MediaQuery.of(context).size.height > 400)
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(40, 70, 40, 40),
                  child: const AppTittle()
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Email field
                      SimpleTextField(
                        enabled: forgotPasswordState is ForgotPasswordStateInitial 
                          || forgotPasswordState is ForgotPasswordStateCodeSentError,
                        title: appLocalizations.emailAddress,
                        maxWidth: 400,
                        controller: emailController,
                        onChanged: (email) {
                          forgotPasswordFormState.setEmail(email);
                        },
                        error: (forgotPasswordState is ForgotPasswordStateCodeSentError) ?
                          forgotPasswordState.error :
                          forgotPasswordForm.email.errorMessage,
                      ),
                      // Password 1 field
                      PasswordTextField(
                        enabled: forgotPasswordState is ForgotPasswordStateCodeSent
                          || forgotPasswordState is ForgotPasswordStateCodeVerifyError,
                        title: appLocalizations.password,
                        maxWidth: 400,
                        controller: passwordController,
                        onChanged: (password) {
                          forgotPasswordFormState.setPassword(password);
                          forgotPasswordFormState.setPassword2(forgotPasswordForm.password2.value);
                        },
                        error: forgotPasswordForm.password.errorMessage,
                      ),
                      // Password 2 field
                      PasswordTextField(
                        enabled: forgotPasswordState is ForgotPasswordStateCodeSent
                          || forgotPasswordState is ForgotPasswordStateCodeVerifyError,
                        title: appLocalizations.repeatPassword,
                        maxWidth: 400,
                        controller: repeatPasswordController,
                        onChanged: (password) {
                          forgotPasswordFormState.setPassword2(password);
                        },
                        error: forgotPasswordForm.password2.errorMessage,
                      ),
                      // Code field
                      SimpleTextField(
                        enabled: forgotPasswordState is ForgotPasswordStateCodeSent
                          || forgotPasswordState is ForgotPasswordStateCodeVerifyError,
                        textAlign: TextAlign.center,
                        maxCharacters: 6,
                        maxWidth: 150,
                        title: appLocalizations.code, 
                        controller: codeController,
                        onChanged: (code) {
                          forgotPasswordFormState.setCode(code);
                          forgotPasswordStateNotifier.setHasCodeSent();
                        },
                        error: (forgotPasswordState is ForgotPasswordStateCodeVerifyError) ?
                          forgotPasswordState.error :
                          forgotPasswordForm.code.errorMessage,
                      ),
                      Flex(
                        direction: (MediaQuery.of(context).size.width <= 700) ? 
                          Axis.vertical : Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 70,
                            width: 250,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                            child:  SimpleTextButton(
                              enabled: forgotPasswordForm.email.isValid
                                && forgotPasswordState is! ForgotPasswordStateLoading,
                              onPressed: () async {
                                await forgotPasswordStateNotifier.requestCode(
                                  forgotPasswordForm.email.value
                                );
                              }, 
                              child: forgotPasswordState is ForgotPasswordStateLoading ?
                                const CircularProgressIndicator() : 
                                Text(
                                  forgotPasswordState is ForgotPasswordStateInitial ?
                                  appLocalizations.sendCode :
                                  appLocalizations.reSendCode
                                )
                            )
                          ),
                          Container(
                            height: 70,
                            width: 250,
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                            child:  SimpleTextButton(
                              enabled: forgotPasswordForm.isValid && forgotPasswordState is ForgotPasswordStateCodeSent,
                              onPressed: () async {
                                await forgotPasswordStateNotifier.verifyCode(
                                  forgotPasswordForm.toModel()
                                );
                                if (ref.read(forgotPasswordStateNotifierProvider) is ForgotPasswordStateSuccess) {
                                  // ignore: use_build_context_synchronously
                                  context.go("/");
                                }
                              },
                              child: forgotPasswordState is ForgotPasswordStateLoading ?
                                const CircularProgressIndicator() : 
                                Text(appLocalizations.verifyCode)
                            )
                          ),
                        ],
                      ),
                    ]
                  ),
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}