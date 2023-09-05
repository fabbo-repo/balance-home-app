import 'package:balance_home_app/src/core/presentation/widgets/app_password_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/domain/values/invitation_code.dart';
import 'package:balance_home_app/src/features/auth/domain/values/email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/register_name.dart';
import 'package:balance_home_app/src/features/auth/domain/values/register_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/register_repeat_password.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:balance_home_app/src/features/currency/presentation/widgets/dropdown_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterForm extends ConsumerStatefulWidget {
  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  @visibleForTesting
  final TextEditingController usernameController;
  @visibleForTesting
  final TextEditingController emailController;
  @visibleForTesting
  final TextEditingController passwordController;
  @visibleForTesting
  final TextEditingController password2Controller;
  @visibleForTesting
  final TextEditingController invitationCodeController;
  @visibleForTesting
  final List<CurrencyTypeEntity> currencyTypes;
  @visibleForTesting
  final formKey = GlobalKey<FormState>();

  RegisterForm(
      {required this.usernameController,
      required this.emailController,
      required this.passwordController,
      required this.password2Controller,
      required this.invitationCodeController,
      required this.currencyTypes,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  @visibleForTesting
  UserName? username;
  @visibleForTesting
  UserEmail? email;
  @visibleForTesting
  UserPassword? password;
  @visibleForTesting
  UserRepeatPassword? repeatPassword;
  @visibleForTesting
  InvitationCode? invitationCode;
  @visibleForTesting
  String? prefCoinType;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    username = UserName(appLocalizations, widget.usernameController.text);
    email = UserEmail(appLocalizations, widget.emailController.text);
    password = UserPassword(appLocalizations, widget.passwordController.text);
    repeatPassword = UserRepeatPassword(appLocalizations,
        widget.passwordController.text, widget.password2Controller.text);
    invitationCode =
        InvitationCode(appLocalizations, widget.invitationCodeController.text);
    final auth = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final emailCode = ref.watch(emailCodeControllerProvider);
    final emailCodeController = ref.read(emailCodeControllerProvider.notifier);
    final isLoading = auth.maybeWhen(
          data: (_) => auth.isRefreshing,
          loading: () => true,
          orElse: () => false,
        ) ||
        emailCode.maybeWhen(
          data: (_) => auth.isRefreshing,
          loading: () => true,
          orElse: () => false,
        );
    widget.cache.value = SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              AppTextFormField(
                maxCharacters: 15,
                maxWidth: 400,
                title: appLocalizations.username,
                controller: widget.usernameController,
                onChanged: (value) =>
                    username = UserName(appLocalizations, value),
                validator: (value) => username?.validate,
              ),
              verticalSpace(),
              AppTextFormField(
                title: appLocalizations.emailAddress,
                maxWidth: 400,
                maxCharacters: 300,
                controller: widget.emailController,
                onChanged: (value) =>
                    email = UserEmail(appLocalizations, value),
                validator: (value) => email?.validate,
              ),
              verticalSpace(),
              AppPasswordTextFormField(
                title: appLocalizations.password,
                maxWidth: 400,
                maxCharacters: 400,
                controller: widget.passwordController,
                onChanged: (value) =>
                    password = UserPassword(appLocalizations, value),
                validator: (value) => password?.validate,
              ),
              verticalSpace(),
              AppPasswordTextFormField(
                title: appLocalizations.repeatPassword,
                maxWidth: 400,
                maxCharacters: 400,
                controller: widget.password2Controller,
                onChanged: (value) => repeatPassword = UserRepeatPassword(
                    appLocalizations, widget.passwordController.text, value),
                validator: (value) => repeatPassword?.validate,
              ),
              verticalSpace(),
              AppTextFormField(
                title: appLocalizations.invitationCode,
                maxWidth: 400,
                maxCharacters: 36,
                controller: widget.invitationCodeController,
                onChanged: (value) =>
                    invitationCode = InvitationCode(appLocalizations, value),
                validator: (value) => invitationCode?.validate,
              ),
              verticalSpace(),
              (widget.currencyTypes.isNotEmpty)
                  ? DropdownPickerField(
                      name: appLocalizations.currencyType,
                      initialValue: widget.currencyTypes[0].code,
                      items: widget.currencyTypes.map((e) => e.code).toList(),
                      onChanged: (value) {
                        prefCoinType = value;
                      })
                  : Text(appLocalizations.genericError),
              verticalSpace(),
              SizedBox(
                  height: 50,
                  width: 240,
                  child: AppTextButton(
                      enabled: !isLoading,
                      onPressed: () async {
                        if (widget.formKey.currentState == null ||
                            !widget.formKey.currentState!.validate()) {
                          return;
                        }
                        if (username == null) return;
                        if (email == null) return;
                        if (password == null) return;
                        if (invitationCode == null) return;
                        if (repeatPassword == null) return;
                        String lang = appLocalizations.localeName;
                        prefCoinType =
                            prefCoinType ?? widget.currencyTypes[0].code;
                        (await authController.createUser(
                                username!,
                                email!,
                                lang,
                                invitationCode!,
                                prefCoinType!,
                                password!,
                                repeatPassword!,
                                appLocalizations))
                            .fold((failure) {
                          showErrorRegisterDialog(
                              appLocalizations, failure.detail);
                        }, (_) async {
                          bool sendCode =
                              await showCodeAdviceDialog(appLocalizations);
                          if (sendCode) {
                            (await emailCodeController.requestCode(
                                    email!, appLocalizations))
                                .fold((failure) {
                              showErrorEmailSendCodeDialog(
                                  appLocalizations, failure.detail);
                            }, (_) {
                              showCodeSendDialog(widget.emailController.text);
                            });
                          }
                        });
                      },
                      text: appLocalizations.register)),
            ],
          ),
        ),
      ),
    );
    return isLoading
        ? showLoading(background: widget.cache.value)
        : widget.cache.value;
  }
}
