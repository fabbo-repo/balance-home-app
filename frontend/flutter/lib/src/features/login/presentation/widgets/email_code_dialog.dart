import 'package:balance_home_app/src/core/presentation/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/simple_text_field.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/auth_state.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/email_code/email_code_provider.dart';
import 'package:balance_home_app/src/features/login/data/models/email_code_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class EmailCodeDialog extends ConsumerStatefulWidget {
  final AppLocalizations appLocalizations;
  final String email;
  final inputController = TextEditingController();

  EmailCodeDialog(
      {required this.appLocalizations, required this.email, super.key});

  @override
  EmailCodeDialogState createState() => EmailCodeDialogState();
}

class EmailCodeDialogState extends ConsumerState<EmailCodeDialog> {
  @override
  Widget build(BuildContext context) {
    final emailCodeForm = ref.watch(emailCodeFormStateProvider).form;
    final emailCodeFormState = ref.read(emailCodeFormStateProvider.notifier);
    final emailCodeState = ref.watch(emailCodeStateNotifierProvider);
    final emailCodeStateNotifier =
        ref.read(emailCodeStateNotifierProvider.notifier);
    return AlertDialog(
      title: Text(widget.appLocalizations.emailVerifiactionCode),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 130),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(widget.appLocalizations.emailVerifiactionSent),
              SimpleTextField(
                textAlign: TextAlign.center,
                maxCharacters: 6,
                maxWidth: 150,
                title: "",
                controller: widget.inputController,
                onChanged: (code) {
                  emailCodeFormState.setCode(code);
                },
                error: emailCodeForm.code.errorMessage,
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        SimpleTextButton(
          enabled: emailCodeForm.isValid && emailCodeState is! AuthStateLoading,
          loading: emailCodeState is AuthStateLoading,
          text: widget.appLocalizations.verifyCode,
          onPressed: () async {
            emailCodeFormState.setEmail(widget.email);
            EmailCodeModel codeModel =
                ref.read(emailCodeFormStateProvider).form.toModel();
            await emailCodeStateNotifier.verifyCode(codeModel);
            AuthState newEmailCodeState =
                ref.read(emailCodeStateNotifierProvider);
            if (newEmailCodeState is! AuthStateError) {
              if (!mounted) return;
              context.go("/");
            } else {
              emailCodeFormState.setCodeError(newEmailCodeState.error);
            }
          },
        ),
        ElevatedButton(
          child: Text(widget.appLocalizations.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
