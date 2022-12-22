import 'package:balance_home_app/src/core/presentation/widgets/info_dialog.dart';
import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceCard extends ConsumerWidget {
  final BalanceModel balance;
  final BalanceTypeEnum balanceTypeEnum;

  const BalanceCard({
    required this.balance,
    required this.balanceTypeEnum,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceRepository = ref.read(balanceRepositoryProvider);
    final balanceListNotifier = (balanceTypeEnum == BalanceTypeEnum.expense) ? 
      ref.read(expenseListProvider.notifier): ref.read(revenueListProvider.notifier);
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    return GestureDetector(
      onTap: () {
        // TODO
      },
      child: Card(
        color: const Color.fromARGB(255, 232, 234, 246),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Image.network(balance.balanceType.image),
              title: Text(balance.name, overflow: TextOverflow.ellipsis),
              subtitle: Text("${balance.quantity} ${balance.coinType}", overflow: TextOverflow.ellipsis),
              trailing: Text("${balance.date.day}-${balance.date.month}-${balance.date.year}"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      // If the button is pressed, return grey, otherwise red
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.grey;
                      }
                      return Colors.red;
                    }),
                  ),
                  onPressed: () async {
                    if (await showDeleteAdviceDialog(context, appLocalizations)) {
                      balanceRepository.deleteBalance(balance, balanceTypeEnum);
                      balanceListNotifier.removeBalance(balance);
                    }
                  },
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

  Future<bool> showDeleteAdviceDialog(BuildContext context, AppLocalizations appLocalizations) async {
    return (await showDialog(
      context: context,
      builder: (context) => InfoDialog(
        dialogTitle: (balanceTypeEnum == BalanceTypeEnum.expense) ? 
          appLocalizations.expenseDialogTitle : appLocalizations.revenueDialogTitle,
        dialogDescription: (balanceTypeEnum == BalanceTypeEnum.expense) ? 
          appLocalizations.expenseDialogDescription : appLocalizations.revenueDialogDescription,
        confirmationText: appLocalizations.confirmation,
        cancelText: appLocalizations.cancel,
        onConfirmation: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      )
    )) ?? false;
  }
}