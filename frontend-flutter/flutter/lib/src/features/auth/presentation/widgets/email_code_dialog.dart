import 'package:balance_home_app/src/core/presentation/widgets/custom_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/verification_code.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class EmailCodeDialog extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final String email;
  final _codeController = TextEditingController();
  VerificationCode? _code;

  EmailCodeDialog({required this.email, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 130),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(appLocalizations.emailVerifiactionSent,
                    overflow: TextOverflow.ellipsis),
                CustomTextFormField(
                  onChanged: (value) =>
                      _code = VerificationCode(appLocalizations, value),
                  textAlign: TextAlign.center,
                  maxCharacters: 6,
                  maxWidth: 200,
                  title: "",
                  controller: _codeController,
                  validator: (value) => _code?.validate ?? errorText,
                )
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        CustomTextButton(
          enabled: !isLoading,
          loading: isLoading,
          text: appLocalizations.verifyCode,
          onPressed: () async {
            if (_formKey.currentState == null ||
                !_formKey.currentState!.validate()) {
              return;
            }
            if (_code == null) return;
            final res = await emailCodeController.verifyCode(
                UserEmail(appLocalizations, email), _code!, appLocalizations);
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
