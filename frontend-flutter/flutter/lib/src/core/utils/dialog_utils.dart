import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_error_dialog.dart';
import 'package:balance_home_app/src/core/presentation/widgets/info_dialog.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/reset_password_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/email_code_dialog.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
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

Future<bool> showCurrencyChangeAdviceDialog(AppLocalizations appLocalizations,
    double newBalance, String currencyType) async {
  return (await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => InfoDialog(
                dialogTitle: appLocalizations.userEditDialogTitle,
                dialogDescription: appLocalizations.userCurrencyChangeDescription
                    .replaceFirst("%%", "$newBalance $currencyType"),
                confirmationText: appLocalizations.confirmation,
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
      builder: (context) => AppErrorDialog(
            dialogTitle: appLocalizations.resetPassword,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorRegisterDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: appLocalizations.register,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorLoginDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: appLocalizations.login,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorEmailSendCodeDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: appLocalizations.sendCode,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorEmailVerifiactionCodeDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: appLocalizations.emailVerifiactionCode,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorBalanceCreationDialog(AppLocalizations appLocalizations,
    String error, BalanceTypeMode balanceTypeMode) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: balanceTypeMode == BalanceTypeMode.expense
                ? appLocalizations.expenseCreateDialogTitle
                : appLocalizations.revenueCreateDialogTitle,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorBalanceEditDialog(AppLocalizations appLocalizations,
    String error, BalanceTypeMode balanceTypeMode) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: balanceTypeMode == BalanceTypeMode.expense
                ? appLocalizations.expenseEditDialogTitle
                : appLocalizations.revenueEditDialogTitle,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorUserEditDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: appLocalizations.userEditDialogTitle,
            dialogDescription: error,
            cancelText: appLocalizations.cancel,
          ));
}

Future<void> showErrorSettingsDialog(
    AppLocalizations appLocalizations, String error) async {
  await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AppErrorDialog(
            dialogTitle: appLocalizations.settingsDialogTitle,
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
