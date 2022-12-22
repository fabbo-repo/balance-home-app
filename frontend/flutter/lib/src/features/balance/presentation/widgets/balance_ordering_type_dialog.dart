

import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_ordering_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceOrderingTypeDialog extends ConsumerWidget {
  final BalanceTypeEnum balanceType;

  const BalanceOrderingTypeDialog({
    required this.balanceType,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceOrderingTypeNotifier = (balanceType == BalanceTypeEnum.expense) ?
      ref.read(expenseOrderingTypeStateNotifierProvider.notifier) : 
      ref.read(revenueOrderingTypeStateNotifierProvider.notifier);
    BalanceOrderingTypeEnum currentType = (balanceType == BalanceTypeEnum.expense) ?
      ref.watch(expenseOrderingTypeStateNotifierProvider).orderingType : 
      ref.watch(revenueOrderingTypeStateNotifierProvider).orderingType;
    final appLocalizations = ref.read(localizationStateNotifierProvider).localization;
    return AlertDialog(
      title: Text(appLocalizations.orderBy),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BalanceOrderingTypeEnum.date,
              BalanceOrderingTypeEnum.name,
              BalanceOrderingTypeEnum.quantity,
            ]
              .map((e) => RadioListTile(
                title: Text(
                  (e == BalanceOrderingTypeEnum.date) ? 
                    appLocalizations.date :
                      (e == BalanceOrderingTypeEnum.name) ?
                        appLocalizations.name :
                          appLocalizations.quantity
                ),
                value: e,
                groupValue: currentType,
                selected: currentType == e,
                onChanged: (value) {
                  if (value != currentType) {
                    Navigator.pop(context);
                    balanceOrderingTypeNotifier.setOrderingType(e);
                  }
                },
              ))
              .toList(),
          ),
        ),
      ));
  }
}