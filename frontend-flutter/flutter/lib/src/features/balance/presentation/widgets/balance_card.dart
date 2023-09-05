import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/info_dialog.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_edit_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BalanceCard extends ConsumerWidget {
  final BalanceEntity balance;
  final BalanceTypeMode balanceTypeMode;
  final dateFormat = DateFormat("dd-MM-yyyy");

  BalanceCard(
      {required this.balance, required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = connectionStateListenable.value;
    final authController = ref.read(authControllerProvider.notifier);
    final balanceListController = balanceTypeMode == BalanceTypeMode.expense
        ? ref.read(expenseListControllerProvider.notifier)
        : ref.read(revenueListControllerProvider.notifier);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return GestureDetector(
      onTap: () {
        context.pushNamed(
            (balanceTypeMode == BalanceTypeMode.expense
                    ? BalanceView.routeExpenseName
                    : BalanceView.routeRevenueName) +
                BalanceEditView.routeName,
            queryParameters: {"id": "${balance.id}"});
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        ),
        color: Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 232, 234, 246)
            : const Color.fromARGB(255, 123, 127, 148),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Image.network(balance.balanceType.image),
              title: Text(balance.name, overflow: TextOverflow.ellipsis),
              subtitle: Text("${balance.realQuantity} ${balance.coinType}",
                  overflow: TextOverflow.ellipsis),
              trailing: Text(dateFormat.format(balance.date)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      // If the button is pressed, return grey, otherwise red
                      if (states.contains(MaterialState.pressed) ||
                          states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return Colors.red;
                    }),
                  ),
                  onPressed: (isConnected)
                      ? () async {
                          if (await showDeleteAdviceDialog(appLocalizations)) {
                            balanceListController.deleteBalance(balance);
                            authController.refreshUserData();
                          }
                        }
                      : null,
                  child: const Icon(
                    Icons.delete,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<bool> showDeleteAdviceDialog(AppLocalizations appLocalizations) async {
    return (await showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => InfoDialog(
                  dialogTitle: balanceTypeMode == BalanceTypeMode.expense
                      ? appLocalizations.expenseDeleteDialogTitle
                      : appLocalizations.revenueDeleteDialogTitle,
                  dialogDescription: balanceTypeMode == BalanceTypeMode.expense
                      ? appLocalizations.expenseDialogDescription
                      : appLocalizations.revenueDialogDescription,
                  confirmationText: appLocalizations.confirmation,
                  cancelText: appLocalizations.cancel,
                  onConfirmation: () => Navigator.pop(context, true),
                  onCancel: () => Navigator.pop(context, false),
                ))) ??
        false;
  }
}
