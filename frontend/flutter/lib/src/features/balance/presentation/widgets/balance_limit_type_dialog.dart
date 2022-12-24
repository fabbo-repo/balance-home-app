import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/models/balance_limit_type.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceLimitTypeDialog extends ConsumerWidget {
  final BalanceTypeMode balanceTypeMode;

  const BalanceLimitTypeDialog({required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceLimitTypeNotifier = balanceTypeMode == BalanceTypeMode.expense
        ? ref.read(expenseLimitTypeProvider.notifier)
        : ref.read(revenueLimitTypeProvider.notifier);
    BalanceLimitType limitType = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseLimitTypeProvider)
        : ref.watch(revenueLimitTypeProvider);
    final appLocalizations = ref.read(appLocalizationsProvider);
    return AlertDialog(
        title: balanceTypeMode == BalanceTypeMode.expense
            ? Text(appLocalizations.maxExpenseDialoTitle)
            : Text(appLocalizations.maxRevenueDialoTitle),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BalanceLimitType.limit5,
                BalanceLimitType.limit15,
                BalanceLimitType.none,
              ]
                  .map((e) => RadioListTile(
                        title: Text(e == BalanceLimitType.limit5
                            ? "5"
                            : e == BalanceLimitType.limit15
                                ? "15"
                                : appLocalizations.noLimit),
                        value: e,
                        groupValue: limitType,
                        selected: limitType == e,
                        onChanged: (value) {
                          if (value != limitType) {
                            Navigator.pop(context);
                            balanceLimitTypeNotifier.setBalanceLimitType(e);
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        ));
  }
}
