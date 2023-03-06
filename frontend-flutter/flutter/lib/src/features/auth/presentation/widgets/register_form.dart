import 'package:balance_home_app/src/core/presentation/widgets/password_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/domain/values/invitation_code.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_name.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_repeat_password.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:balance_home_app/src/features/coin/presentation/widgets/dropdown_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterForm extends ConsumerStatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController password2Controller;
  final TextEditingController invitationCodeController;
  final List<CoinTypeEntity> coinTypes;
  final _formKey = GlobalKey<FormState>();

  RegisterForm(
      {required this.usernameController,
      required this.emailController,
      required this.passwordController,
      required this.password2Controller,
      required this.invitationCodeController,
      required this.coinTypes,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  UserName? _username;
  UserEmail? _email;
  UserPassword? _password;
  UserRepeatPassword? _repeatPassword;
  InvitationCode? _invitationCode;
  Widget cache = Container();
  String? prefCoinType;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    _username = UserName(appLocalizations, widget.usernameController.text);
    _email = UserEmail(appLocalizations, widget.emailController.text);
    _password = UserPassword(appLocalizations, widget.passwordController.text);
    _repeatPassword = UserRepeatPassword(appLocalizations,
        widget.passwordController.text, widget.password2Controller.text);
    _invitationCode =
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
    cache = SingleChildScrollView(
      child: Form(
        key: widget._formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              CustomTextFormField(
                maxCharacters: 15,
                maxWidth: 400,
                title: appLocalizations.username,
                controller: widget.usernameController,
                onChanged: (value) =>
                    _username = UserName(appLocalizations, value),
                validator: (value) => _username?.validate,
              ),
              verticalSpace(),
              CustomTextFormField(
                title: appLocalizations.emailAddress,
                maxWidth: 400,
                maxCharacters: 300,
                controller: widget.emailController,
                onChanged: (value) =>
                    _email = UserEmail(appLocalizations, value),
                validator: (value) => _email?.validate,
              ),
              verticalSpace(),
              PasswordTextFormField(
                title: appLocalizations.password,
                maxWidth: 400,
                maxCharacters: 400,
                controller: widget.passwordController,
                onChanged: (value) =>
                    _password = UserPassword(appLocalizations, value),
                validator: (value) => _password?.validate,
              ),
              verticalSpace(),
              PasswordTextFormField(
                title: appLocalizations.repeatPassword,
                maxWidth: 400,
                maxCharacters: 400,
                controller: widget.password2Controller,
                onChanged: (value) => _repeatPassword = UserRepeatPassword(
                    appLocalizations, widget.passwordController.text, value),
                validator: (value) => _repeatPassword?.validate,
              ),
              verticalSpace(),
              CustomTextFormField(
                title: appLocalizations.invitationCode,
                maxWidth: 400,
                maxCharacters: 36,
                controller: widget.invitationCodeController,
                onChanged: (value) =>
                    _invitationCode = InvitationCode(appLocalizations, value),
                validator: (value) => _invitationCode?.validate,
              ),
              verticalSpace(),
              (widget.coinTypes.isNotEmpty)
                  ? DropdownPickerField(
                      name: appLocalizations.coinType,
                      initialValue: widget.coinTypes[0].code,
                      items: widget.coinTypes.map((e) => e.code).toList(),
                      onChanged: (value) {
                        prefCoinType = value;
                      })
                  : Text(appLocalizations.genericError),
              verticalSpace(),
              SizedBox(
                  height: 50,
                  width: 240,
                  child: CustomTextButton(
                      enabled: !isLoading,
                      onPressed: () async {
                        if (widget._formKey.currentState == null ||
                            !widget._formKey.currentState!.validate()) {
                          return;
                        }
                        if (_username == null) return;
                        if (_email == null) return;
                        if (_password == null) return;
                        if (_invitationCode == null) return;
                        if (_repeatPassword == null) return;
                        String lang = appLocalizations.localeName;
                        prefCoinType = prefCoinType ?? widget.coinTypes[0].code;
                        (await authController.createUser(
                                _username!,
                                _email!,
                                lang,
                                _invitationCode!,
                                prefCoinType!,
                                _password!,
                                _repeatPassword!,
                                appLocalizations))
                            .fold((l) {
                          showErrorRegisterDialog(appLocalizations, l.error);
                        }, (r) async {
                          bool sendCode =
                              await showCodeAdviceDialog(appLocalizations);
                          if (sendCode) {
                            (await emailCodeController.requestCode(
                                    _email!, appLocalizations))
                                .fold((l) {
                              showErrorEmailSendCodeDialog(
                                  appLocalizations, l.error);
                            }, (r) {
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
    return isLoading ? showLoading(cache: cache) : cache;
  }
}
