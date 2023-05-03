import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/password_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/text_check_box.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/domain/values/login_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends ConsumerStatefulWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController;
  final TextEditingController passwordController;

  LoginForm(
      {required this.emailController,
      required this.passwordController,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  UserEmail? _email;
  LoginPassword? _password;
  bool storeCredentials = false;
  Widget cache = Container();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    _email = UserEmail(appLocalizations, widget.emailController.text);
    _password = LoginPassword(appLocalizations, widget.passwordController.text);
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
              AppTextFormField(
                maxWidth: 400,
                maxCharacters: 300,
                title: appLocalizations.emailAddress,
                controller: widget.emailController,
                onChanged: (value) =>
                    _email = UserEmail(appLocalizations, value),
                validator: (value) => _email?.validate,
              ),
              verticalSpace(),
              PasswordTextFormField(
                maxWidth: 400,
                maxCharacters: 400,
                title: appLocalizations.password,
                controller: widget.passwordController,
                onChanged: (value) =>
                    _password = LoginPassword(appLocalizations, value),
                validator: (value) => _password?.validate,
              ),
              verticalSpace(),
              TextCheckBox(
                title: appLocalizations.storeCredentials,
                fillColor: const Color.fromARGB(255, 65, 65, 65),
                onChanged: (value) {
                  storeCredentials = value!;
                },
              ),
              verticalSpace(),
              SizedBox(
                  height: 50,
                  width: 200,
                  child: AppTextButton(
                      enabled: !isLoading,
                      onPressed: () async {
                        if (widget._formKey.currentState == null ||
                            !widget._formKey.currentState!.validate()) {
                          return;
                        }
                        if (_email == null) return;
                        if (_password == null) return;
                        (await authController.signIn(
                                _email!, _password!, appLocalizations,
                                store: storeCredentials))
                            .fold((failure) async {
                          if (failure.detail ==
                              appLocalizations.emailNotVerified) {
                            bool sendCode =
                                await showCodeAdviceDialog(appLocalizations);
                            if (sendCode) {
                              (await emailCodeController.requestCode(
                                      _email!, appLocalizations))
                                  .fold((failure) {
                                showErrorEmailSendCodeDialog(
                                    appLocalizations, failure.detail);
                              }, (_) {
                                showCodeSendDialog(widget.emailController.text);
                              });
                            }
                          } else {
                            showErrorLoginDialog(
                                appLocalizations, failure.detail);
                          }
                        }, (_) {
                          navigatorKey.currentContext!
                              .go("/${StatisticsView.routePath}");
                        });
                      },
                      text: appLocalizations.signIn)),
              verticalSpace(),
              TextButton(
                onPressed: () {
                  ref
                      .read(resetPasswordControllerProvider.notifier)
                      .resetProgress();
                  showResetPasswordAdviceDialog(appLocalizations);
                },
                child: Text(
                  appLocalizations.forgotPassword,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 65, 65, 65)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return isLoading
        ? showLoading(background: cache, alignment: AlignmentDirectional.topStart)
        : cache;
  }
}
