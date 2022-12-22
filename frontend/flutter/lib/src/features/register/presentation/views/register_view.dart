import 'package:balance_home_app/src/core/presentation/widgets/password_text_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/simple_text_field.dart';
import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/email_code/email_code_provider.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/utils.dart';
import 'package:balance_home_app/src/features/coin/data/models/coin_type_model.dart';
import 'package:balance_home_app/src/features/coin/presentation/widgets/dropdown_picker_field.dart';
import 'package:balance_home_app/src/features/register/data/models/register_model.dart';
import 'package:balance_home_app/src/features/register/logic/providers/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends ConsumerStatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController password2Controller;
  final TextEditingController invitationCodeController;
  final List<CoinTypeModel> coinTypes;

  const RegisterView({
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.password2Controller,
    required this.invitationCodeController,
    required this.coinTypes, 
    Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  String? prefCoinType;

  @override
  Widget build(BuildContext context) {
    final registerForm  = ref.watch(registerFormStateProvider).form;
    final registerFormState = ref.read(registerFormStateProvider.notifier);
    final registerState = ref.watch(registerStateNotifierProvider);
    final registerStateNotifier = ref.read(registerStateNotifierProvider.notifier);
    final emailCodeStateNotifier = ref.read(emailCodeStateNotifierProvider.notifier);
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SimpleTextField(
              maxCharacters: 15,
              maxWidth: 400,
              title: appLocalizations.username,
              controller: widget.usernameController,
              onChanged: (username) {
                registerFormState.setUsername(username);
              },
              error: registerForm.username.errorMessage,
            ),
            SimpleTextField(
              title: appLocalizations.emailAddress,
              maxWidth: 400,
              controller: widget.emailController,
              onChanged: (email) {
                registerFormState.setEmail(email);
              },
              error: registerForm.email.errorMessage,
            ),
            PasswordTextField(
              title: appLocalizations.password,
              maxWidth: 400,
              controller: widget.passwordController,
              onChanged: (password) {
                registerFormState.setPassword(password);
                registerFormState.setPassword2(registerForm.password2.value);
              },
              error: registerForm.password.errorMessage,
            ),
            PasswordTextField(
              title: appLocalizations.repeatPassword,
              maxWidth: 400,
              controller: widget.password2Controller,
              onChanged: (password2) {
                registerFormState.setPassword2(password2);
              },
              error: registerForm.password2.errorMessage,
            ),
            SimpleTextField(
              title: appLocalizations.invitationCode,
              maxWidth: 450,
              maxCharacters: 36,
              controller: widget.invitationCodeController,
              onChanged: (invitationCode) {
                registerFormState.setInvitationCode(invitationCode);
              },
              error: registerForm.invCode.errorMessage,
            ),
            (widget.coinTypes.isNotEmpty) ?
              DropdownPickerField(
                name: appLocalizations.coinType,
                initialValue: widget.coinTypes[0].code,
                items: widget.coinTypes.map((e) => e.code).toList(),
                onChanged: (value) {
                  prefCoinType = value;
                }
              ) :
              Text(appLocalizations.genericError)
            ,
            Text(
              (registerState is AuthStateError) ?
              registerState.error : 
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
                enabled: registerForm.isValid
                  && registerState is! AuthStateLoading,
                onPressed: () async {
                  registerFormState.setLanguage(appLocalizations.localeName);
                  registerFormState.setPrefCoinType(prefCoinType ?? widget.coinTypes[0].code);
                  RegisterModel registration = ref.read(registerFormStateProvider).form.toModel();
                  await registerStateNotifier.createAccount(registration);
                  if (ref.read(registerStateNotifierProvider) is AuthStateSuccess) {
                    if (!mounted) return;
                    bool sendCode = await showCodeAdviceDialog(context, appLocalizations);
                    if (sendCode) {
                      await emailCodeStateNotifier.requestCode(registration.email);
                      AuthState newEmailCodeState = ref.read(emailCodeStateNotifierProvider);
                      if (newEmailCodeState is! AuthStateError) {
                        if (!mounted) return;
                        showCodeSendDialog(context, appLocalizations, registration.email);
                      } else {
                        if (!mounted) return;
                        showErrorCodeDialog(context, appLocalizations, newEmailCodeState.error);
                      }
                    }
                  }
                }, 
                child: ref.read(registerStateNotifierProvider) is AuthStateLoading ?
                  const CircularProgressIndicator() : 
                  Text(appLocalizations.register)
              )
            ),
          ],
        ),
      ),
    );
  }
}