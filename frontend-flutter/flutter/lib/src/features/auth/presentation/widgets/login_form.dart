import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_password_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_check_box.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/domain/values/login_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/email.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginForm extends ConsumerStatefulWidget {
  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  @visibleForTesting
  final formKey = GlobalKey<FormState>();
  @visibleForTesting
  final TextEditingController emailController;
  @visibleForTesting
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
  @visibleForTesting
  UserEmail? email;
  @visibleForTesting
  LoginPassword? password;
  @visibleForTesting
  bool storeCredentials = false;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    email = UserEmail(appLocalizations, widget.emailController.text);
    password = LoginPassword(appLocalizations, widget.passwordController.text);
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
                maxWidth: 400,
                maxCharacters: 300,
                title: appLocalizations.emailAddress,
                controller: widget.emailController,
                onChanged: (value) =>
                    email = UserEmail(appLocalizations, value),
                validator: (value) => email?.validate,
              ),
              verticalSpace(),
              AppPasswordTextFormField(
                maxWidth: 400,
                maxCharacters: 400,
                title: appLocalizations.password,
                controller: widget.passwordController,
                onChanged: (value) =>
                    password = LoginPassword(appLocalizations, value),
                validator: (value) => password?.validate,
              ),
              verticalSpace(),
              AppTextCheckBox(
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
                        if (widget.formKey.currentState == null ||
                            !widget.formKey.currentState!.validate()) {
                          return;
                        }
                        if (email == null) return;
                        if (password == null) return;
                        (await authController.signIn(
                                email!, password!, appLocalizations,
                                store: storeCredentials))
                            .fold((failure) async {
                          if (failure.detail ==
                              appLocalizations.emailNotVerified) {
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
                          } else {
                            showErrorLoginDialog(
                                appLocalizations, failure.detail);
                          }
                        }, (_) {
                          router.goNamed(StatisticsView.routeName);
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
                  style: GoogleFonts.openSans(
                      color: const Color.fromARGB(255, 65, 65, 65)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return isLoading
        ? showLoading(
            background: widget.cache.value,
            alignment: AlignmentDirectional.topStart)
        : widget.cache.value;
  }
}
