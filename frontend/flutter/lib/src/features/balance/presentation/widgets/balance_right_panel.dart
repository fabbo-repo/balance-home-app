import 'package:balance_home_app/src/core/providers/localization/localization_provider.dart';
import 'package:balance_home_app/src/core/widgets/simple_text_button.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_limit_type_dialog.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_list.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_ordering_type_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanaceRightPanel extends ConsumerWidget {
  final BalanceTypeEnum balanceTypeEnum;
  
  const BalanaceRightPanel({
    required this.balanceTypeEnum,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    return Container(
      color: (balanceTypeEnum == BalanceTypeEnum.expense) ?
        const Color.fromARGB(254, 236, 182, 163) : 
        const Color.fromARGB(254, 174, 221, 148),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SimpleTextButton(
                width: 160,
                height: 40,
                backgroundColor: Colors.white,
                onPressed: () {
                  showOrderingDialog(context);
                }, 
                child: Text(appLocalizations.orderBy)
              ),
              const SizedBox(width: 30),
              SimpleTextButton(
                width: 160,
                height: 40,
                backgroundColor: Colors.white,
                onPressed: () {
                  showLimitDialog(context);
                }, 
                child: Text(appLocalizations.limit)
              )
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: BalanceList(balanceTypeEnum: balanceTypeEnum)),
        ],
      ),
    );
  }

  @visibleForTesting
  showOrderingDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) {
      return BalanceOrderingTypeDialog(
        balanceTypeEnum: balanceTypeEnum);
    }
  );
  
  @visibleForTesting
  showLimitDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) {
      return BalanceLimitTypeDialog(
        balanceTypeEnum: balanceTypeEnum);
    }
  );
}