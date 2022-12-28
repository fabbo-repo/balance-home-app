import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/models/balance_ordering_type.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceOrderingTypeDialog extends ConsumerWidget {
  final BalanceTypeMode balanceTypeMode;

  const BalanceOrderingTypeDialog({required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceOrderingTypeNotifier =
        balanceTypeMode == BalanceTypeMode.expense
            ? ref.read(expenseOrderingTypeProvider.notifier)
            : ref.read(revenueOrderingTypeProvider.notifier);
    BalanceOrderingType orderingType =
        balanceTypeMode == BalanceTypeMode.expense
            ? ref.watch(expenseOrderingTypeProvider)
            : ref.watch(revenueOrderingTypeProvider);
    final appLocalizations = ref.read(appLocalizationsProvider);
    return AlertDialog(
        title: Text(appLocalizations.orderBy),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BalanceOrderingType.date,
                BalanceOrderingType.name,
                BalanceOrderingType.quantity,
              ]
                  .map((e) => RadioListTile(
                        title: Text((e == BalanceOrderingType.date)
                            ? appLocalizations.date
                            : (e == BalanceOrderingType.name)
                                ? appLocalizations.name
                                : appLocalizations.quantity),
                        value: e,
                        groupValue: orderingType,
                        selected: orderingType == e,
                        onChanged: (value) {
                          if (value != orderingType) {
                            Navigator.pop(context);
                            balanceOrderingTypeNotifier
                                .setBalanceOrderingType(e);
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        ));
  }
}
