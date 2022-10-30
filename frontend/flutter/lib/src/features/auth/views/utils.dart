
import 'package:balance_home_app/src/core/widgets/error_dialog.dart';
import 'package:balance_home_app/src/core/widgets/info_dialog.dart';
import 'package:balance_home_app/src/features/login/presentation/views/email_code_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showCodeAdviceDialog(context, appLocalizations) async {
  return await showDialog(
    context: context,
    builder: (context) => InfoDialog(
      dialogTitle: appLocalizations.emailVerifiactionCode,
      dialogDescription: appLocalizations.emailVerifiactionAdvice,
      confirmationText: appLocalizations.sendCode,
      cancelText: appLocalizations.cancel,
      onConfirmation: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context, false),
    )
  );
}

Future<void> showErrorCodeDialog(context, appLocalizations, error) async {
  await showDialog(
    context: context,
    builder: (context) => ErrorDialog(
      dialogTitle: appLocalizations.emailVerifiactionCode,
      dialogDescription: error,
      cancelText: appLocalizations.cancel,
    )
  );
}

Future<void> showCodeSendDialog(context, appLocalizations, email) async {
  await showDialog(
    context: context,
    builder: (context) => EmailCodeDialog(
      appLocalizations: appLocalizations,
      email: email,
    )
  );
} 