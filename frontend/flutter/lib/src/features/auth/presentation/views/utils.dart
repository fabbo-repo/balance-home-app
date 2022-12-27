import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/error_dialog.dart';
import 'package:balance_home_app/src/core/presentation/widgets/info_dialog.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/reset_password_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/email_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

Future<bool> showCodeAdviceDialog(AppLocalizations appLocalizations) async {
  return (await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => InfoDialog(
                dialogTitle: appLocalizations.emailVerifiactionCode,
                dialogDescription: appLocalizations.emailVerifiactionAdvice,
                confirmationText: appLocalizations.sendCode,
                cancelText: appLocalizations.cancel,
                onConfirmation: () => Navigator.pop(context, true),
                onCancel: () => Navigator.pop(context, false),
              ))) ??
      false;
}

Future<void> showResetPasswordAdviceDialog(
    AppLocalizations appLocalizations) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => InfoDialog(
          dialogTitle: appLocalizations.resetPassword,
          dialogDescription: appLocalizations.resetPasswordAdvice,
          confirmationText: appLocalizations.confirmation,
          cancelText: appLocalizations.cancel,
          onConfirmation: () {
            // Pop current dialog
            Navigator.pop(context);
            // Push route
            context.pushNamed(ResetPasswordView.routeName);
          }));
}

Future<void> showErrorResetPasswordCodeDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => ErrorDialog(
            dialogTitle: appLocalizations.resetPassword,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorLoginDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => ErrorDialog(
            dialogTitle: appLocalizations.login,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorEmailSendCodeDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => ErrorDialog(
            dialogTitle: appLocalizations.sendCode,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorEmailVerifiactionCodeDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => ErrorDialog(
            dialogTitle: appLocalizations.emailVerifiactionCode,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showCodeSendDialog(String email) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => EmailCodeDialog(
            email: email,
          ));
}
