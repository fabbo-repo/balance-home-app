import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/info_dialog.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/user_edit_view.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserDeleteView extends ConsumerWidget {
  /// Named route for [UserDeleteView]
  static const String routeName = 'deleteUser';

  /// Path route for [UserDeleteView]
  static const String routePath = 'delete-user';

  const UserDeleteView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    Future.microtask(() {
      showDeleteAdviceDialog(navigatorKey.currentContext!, appLocalizations)
          .then((value) async {
        if (value) {
          (await authController.deleteUser()).fold((_) {
            ErrorView.go();
          }, (_) {
            navigatorKey.currentContext!.goNamed(AuthView.routeName);
          });
        } else {
          navigatorKey.currentContext!.pop();
        }
      });
    });
    return const Scaffold(
        body: LoadingWidget(
      color: Colors.red,
    ));
  }

  Future<bool> showDeleteAdviceDialog(
      BuildContext context, AppLocalizations appLocalizations) async {
    return (await showDialog(
            context: context,
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
