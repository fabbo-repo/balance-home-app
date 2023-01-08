import 'package:balance_home_app/src/core/presentation/widgets/custom_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/password_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/application/reset_password_controller.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_repeat_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/verification_code.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordForm extends ConsumerStatefulWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  ResetPasswordForm({
    super.key,
  });

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  UserEmail? _email;
  UserPassword? _password;
  UserRepeatPassword? _repeatPassword;
  VerificationCode? _code;
  Widget cache = Container();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    _email = UserEmail(appLocalizations, widget._emailController.text);
    final res = ref.watch(resetPasswordControllerProvider);
    final resetPasswordController =
        ref.read(resetPasswordControllerProvider.notifier);
    return res.when(data: (progress) {
      if (progress == ResetPasswordProgress.started) {
        _password =
            UserPassword(appLocalizations, widget._passwordController.text);
        _repeatPassword = UserRepeatPassword(
            appLocalizations,
            widget._passwordController.text,
            widget._repeatPasswordController.text);
        _code = VerificationCode(appLocalizations, widget._codeController.text);
      }
      return Form(
        key: widget._formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              verticalSpace(),
              CustomTextFormField(
                onChanged: (value) =>
                    _email = UserEmail(appLocalizations, value),
                title: appLocalizations.emailAddress,
                validator: (value) => _email?.validate,
                readOnly: progress != ResetPasswordProgress.none,
                maxCharacters: 300,
                maxWidth: 400,
                controller: widget._emailController,
              ),
              verticalSpace(),
              PasswordTextFormField(
                onChanged: (value) =>
                    _password = UserPassword(appLocalizations, value),
                title: appLocalizations.password,
                validator: (value) => _password?.validate,
                readOnly: progress != ResetPasswordProgress.started,
                maxCharacters: 500,
                maxWidth: 400,
                controller: widget._passwordController,
              ),
              PasswordTextFormField(
                onChanged: (value) => _repeatPassword = UserRepeatPassword(
                    appLocalizations, widget._passwordController.text, value),
                title: appLocalizations.repeatPassword,
                validator: (value) => _repeatPassword?.validate,
                readOnly: progress != ResetPasswordProgress.started,
                maxCharacters: 500,
                maxWidth: 400,
                controller: widget._repeatPasswordController,
              ),
              verticalSpace(),
              CustomTextFormField(
                onChanged: (value) =>
                    _code = VerificationCode(appLocalizations, value),
                title: appLocalizations.code,
                validator: (value) => _code?.validate,
                readOnly: progress != ResetPasswordProgress.started,
                maxCharacters: 6,
                maxWidth: 200,
                controller: widget._codeController,
                textAlign: TextAlign.center,
              ),
              verticalSpace(),
              CustomTextButton(
                width: 200,
                height: 50,
                onPressed: () async {
                  if (progress == ResetPasswordProgress.none &&
                      !widget._formKey.currentState!.validate()) {
                    return;
                  }
                  if (_email == null) return;
                  (await resetPasswordController.requestCode(
                          _email!, appLocalizations,
                          retry: progress == ResetPasswordProgress.started))
                      .fold((l) {
                    showErrorResetPasswordCodeDialog(appLocalizations, l.error);
                  }, (r) {});
                },
                text: progress == ResetPasswordProgress.none
                    ? appLocalizations.sendCode
                    : appLocalizations.reSendCode,
              ),
              verticalSpace(),
              CustomTextButton(
                width: 200,
                height: 50,
                enabled: progress == ResetPasswordProgress.started,
                onPressed: () async {
                  if (widget._formKey.currentState == null ||
                      !widget._formKey.currentState!.validate()) {
                    return;
                  }
                  if (_email == null) return;
                  if (_password == null) return;
                  if (_repeatPassword == null) return;
                  if (_code == null) return;
                  (await resetPasswordController.verifyCode(
                          _email!, _code!, _password!, appLocalizations))
                      .fold((l) {
                    showErrorResetPasswordCodeDialog(appLocalizations, l.error);
                  }, (r) {
                    context.go("/${AuthView.routePath}");
                  });
                },
                text: appLocalizations.verifyCode,
              ),
            ],
          ),
        ),
      );
    }, error: (o, st) {
      return showError(o, st, cache: cache);
    }, loading: () {
      return showLoading(cache: cache);
    });
  }
}
