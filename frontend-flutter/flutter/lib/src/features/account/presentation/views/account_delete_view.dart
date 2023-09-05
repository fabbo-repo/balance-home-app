import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/info_dialog.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountDeleteView extends ConsumerWidget {
  /// Named route for [AccountDeleteView]
  static const String routeName = 'accountDelete';

  /// Path route for [AccountDeleteView]
  static const String routePath = 'account-delete';

  const AccountDeleteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    Future.microtask(() {
      showDeleteAdviceDialog(appLocalizations).then((value) async {
        if (value) {
          (await authController.deleteUser()).fold((_) {
            AppErrorView.go();
          }, (_) {
            router.goNamed(AuthView.routeName);
          });
        } else {
          router.pop();
        }
      });
    });
    return const Scaffold(
        body: AppLoadingWidget(
      color: Colors.red,
    ));
  }

  Future<bool> showDeleteAdviceDialog(AppLocalizations appLocalizations) async {
    return (await showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => InfoDialog(
                  dialogTitle: appLocalizations.userDeleteDialogTitle,
                  dialogDescription: appLocalizations.userDialogDescription,
                  confirmationText: appLocalizations.confirmation,
                  cancelText: appLocalizations.cancel,
                  onConfirmation: () => Navigator.pop(context, true),
                  onCancel: () => Navigator.pop(context, false),
                ))) ??
        false;
  }
}
