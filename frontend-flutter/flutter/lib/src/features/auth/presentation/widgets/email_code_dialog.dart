import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/domain/values/email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/verification_code.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmailCodeDialog extends ConsumerStatefulWidget {
  @visibleForTesting
  final formKey = GlobalKey<FormState>();
  @visibleForTesting
  final String email;
  @visibleForTesting
  final codeController = TextEditingController();

  EmailCodeDialog({required this.email, super.key});

  @override
  ConsumerState<EmailCodeDialog> createState() => _EmailCodeDialogState();
}

class _EmailCodeDialogState extends ConsumerState<EmailCodeDialog> {
  @visibleForTesting
  VerificationCode? code;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final res = ref.watch(emailCodeControllerProvider);
    final emailCodeController = ref.read(emailCodeControllerProvider.notifier);
    final errorText = res.maybeWhen(
      error: (error, stackTrace) => error.toString(),
      orElse: () => null,
    );
    final isLoading = res.maybeWhen(
      data: (_) => res.isRefreshing,
      loading: () => true,
      orElse: () => false,
    );
    return AlertDialog(
      title: Text(appLocalizations.emailVerifiactionCode),
      content: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 130),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(appLocalizations.emailVerifiactionSent,
                    overflow: TextOverflow.ellipsis),
                AppTextFormField(
                  onChanged: (value) =>
                      code = VerificationCode(appLocalizations, value),
                  textAlign: TextAlign.center,
                  maxCharacters: 6,
                  maxWidth: 200,
                  title: "",
                  controller: widget.codeController,
                  validator: (value) => code?.validate ?? errorText,
                )
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        AppTextButton(
          enabled: !isLoading,
          loading: isLoading,
          text: appLocalizations.verifyCode,
          onPressed: () async {
            if (widget.formKey.currentState == null ||
                !widget.formKey.currentState!.validate()) {
              return;
            }
            if (code == null) return;
            final res = await emailCodeController.verifyCode(
                UserEmail(appLocalizations, widget.email),
                code!,
                appLocalizations);
            res.fold((_) {}, (_) {
              context.go("/");
            });
          },
        ),
        ElevatedButton(
          child: Text(appLocalizations.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
