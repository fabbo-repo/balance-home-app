
import 'package:balance_home_app/src/core/widgets/error_dialog.dart';
import 'package:balance_home_app/src/core/widgets/info_dialog.dart';
import 'package:balance_home_app/src/features/login/presentation/widgets/email_code_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

Future<bool> showCodeAdviceDialog(BuildContext context, AppLocalizations appLocalizations) async {
  return (await showDialog(
    context: context,
    builder: (context) => InfoDialog(
      dialogTitle: appLocalizations.emailVerifiactionCode,
      dialogDescription: appLocalizations.emailVerifiactionAdvice,
      confirmationText: appLocalizations.sendCode,
      cancelText: appLocalizations.cancel,
      onConfirmation: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    )
  )) ?? false;
}

Future<void> showResetPasswordAdviceDialog(BuildContext context, AppLocalizations appLocalizations) async {
  await showDialog(
    context: context,
    builder: (context) => InfoDialog(
      dialogTitle: appLocalizations.resetPassword,
      dialogDescription: appLocalizations.resetPasswordAdvice,
      confirmationText: appLocalizations.confirmation,
      cancelText: appLocalizations.cancel,
      onConfirmation: () {
        // Pop current dialog
        Navigator.pop(context);
        // Push route
        context.push("/password/reset");
      }
    )
  );
}

Future<void> showErrorCodeDialog(BuildContext context, AppLocalizations appLocalizations, String error) async {
  await showDialog(
    context: context,
    builder: (context) => ErrorDialog(
      dialogTitle: appLocalizations.emailVerifiactionCode,
      dialogDescription: error,
      cancelText: appLocalizations.cancel,
    )
  );
}

Future<void> showCodeSendDialog(BuildContext context, AppLocalizations appLocalizations, String email) async {
  await showDialog(
    context: context,
    builder: (context) => EmailCodeDialog(
      appLocalizations: appLocalizations,
      email: email,
    )
  );
} 