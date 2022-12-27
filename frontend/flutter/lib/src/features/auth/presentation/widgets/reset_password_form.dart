import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/password_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/simple_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/application/reset_password_controller.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_repeat_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/verification_code.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class ResetPasswordForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  UserEmail? _email;
  UserPassword? _password;
  UserRepeatPassword? _repeatPassword;
  VerificationCode? _code;
  Widget cache = Container();

  ResetPasswordForm({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final res = ref.watch(resetPasswordControllerProvider);
    final resetPasswordController =
        ref.read(resetPasswordControllerProvider.notifier);
    return res.when(data: (progress) {
      return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              space(),
              SimpleTextFormField(
                onChanged: (value) =>
                    _email = UserEmail(appLocalizations, value),
                title: appLocalizations.emailAddress,
                validator: (value) => _email?.validate,
                readOnly: progress != ResetPasswordProgress.none,
                maxCharacters: 300,
                maxWidth: 400,
                controller: _emailController,
              ),
              space(),
              PasswordTextFormField(
                onChanged: (value) =>
                    _password = UserPassword(appLocalizations, value),
                title: appLocalizations.password,
                validator: (value) => _password?.validate,
                readOnly: progress != ResetPasswordProgress.started,
                maxCharacters: 500,
                maxWidth: 400,
                controller: _passwordController,
              ),
              PasswordTextFormField(
                onChanged: (value) => _repeatPassword = UserRepeatPassword(
                    appLocalizations, _passwordController.text, value),
                title: appLocalizations.repeatPassword,
                validator: (value) => _repeatPassword?.validate,
                readOnly: progress != ResetPasswordProgress.started,
                maxCharacters: 500,
                maxWidth: 400,
                controller: _repeatPasswordController,
              ),
              space(),
              SimpleTextFormField(
                onChanged: (value) =>
                    _code = VerificationCode(appLocalizations, value),
                title: appLocalizations.code,
                validator: (value) => _code?.validate,
                readOnly: progress != ResetPasswordProgress.started,
                maxCharacters: 6,
                maxWidth: 200,
                controller: _codeController,
                textAlign: TextAlign.center,
              ),
              space(),
              ElevatedButton(
                onPressed: _formKey.currentState == null ||
                        !_formKey.currentState!.validate()
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        if (_email == null) return;
                        (await resetPasswordController.requestCode(
                                _email!, appLocalizations))
                            .fold((l) {
                          showErrorResetPasswordCodeDialog(
                              appLocalizations, l.error);
                        }, (r) {});
                      },
                child: progress != ResetPasswordProgress.none
                    ? Text(appLocalizations.sendCode)
                    : Text(appLocalizations.reSendCode),
              ),
              space(),
              ElevatedButton(
                onPressed: progress != ResetPasswordProgress.started
                    ? null
                    : () async {
                        if (_formKey.currentState == null ||
                            !_formKey.currentState!.validate()) {
                          return;
                        }
                        if (_email == null) return;
                        if (_password == null) return;
                        if (_repeatPassword == null) return;
                        if (_code == null) return;
                        (await resetPasswordController.verifyCode(
                                _email!, _code!, _password!, appLocalizations))
                            .fold((l) {
                          showErrorResetPasswordCodeDialog(
                              appLocalizations, l.error);
                        }, (r) {
                          context.go("/${AuthView.routePath}");
                        });
                        ;
                      },
                child: Text(appLocalizations.verifyCode),
              ),
            ],
          ),
        ),
      );
    }, error: (error, stackTrace) {
      debugPrint("[RESET_PASSWORD_FORM] $error -> $stackTrace");
      return Stack(alignment: AlignmentDirectional.centerStart, children: [
        cache,
        const CustomErrorWidget(),
      ]);
    }, loading: () {
      return Stack(alignment: AlignmentDirectional.centerStart, children: [
        cache,
        const LoadingWidget(color: Colors.grey),
      ]);
    });
  }

  @visibleForTesting
  Widget space() {
    return const SizedBox(
      height: AppLayout.genericPadding,
    );
  }
}
