import 'package:balance_home_app/src/features/balance/data/models/balance_limit_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_ordering_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_provider.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceList extends ConsumerWidget {
  final BalanceTypeEnum balanceType;

  const BalanceList({
    required this.balanceType,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceListProvider = (balanceType == BalanceTypeEnum.expense) ? 
      ref.watch(expenseListProvider) : ref.watch(revenueListProvider);
    final orderingType = (balanceType == BalanceTypeEnum.expense) ? 
      ref.watch(expenseOrderingTypeStateNotifierProvider).orderingType
      : ref.watch(revenueOrderingTypeStateNotifierProvider).orderingType;
    final limitType = (balanceType == BalanceTypeEnum.expense) ? 
      ref.watch(expenseLimitTypeStateNotifierProvider).limitType
      : ref.watch(revenueLimitTypeStateNotifierProvider).limitType;
    List<BalanceModel> balanceList = orderBy(balanceListProvider.models, orderingType, limitType);
    return Stack(
      children: <Widget>[
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: balanceList.length,
          itemBuilder: (BuildContext context, int index) {
            return BalanceCard(
              balance: balanceList[index], 
              balanceTypeEnum: balanceType
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            onPressed: () {
              // TODO Add your onPressed code here!
            },
            backgroundColor: (balanceType == BalanceTypeEnum.expense) ? 
              Colors.orange : Colors.green,
            child: const Icon(Icons.add),
          ),
        ),
      ]
    );
  }
  
  @visibleForTesting
  List<BalanceModel> orderBy(
    List<BalanceModel> balances, 
    BalanceOrderingTypeEnum orderingType,
    BalanceLimitTypeEnum limitType
  ) {
    List<BalanceModel> aux = [];
    for (BalanceModel balance in balances) {
      int i = 0;
      while (i < aux.length) {
        // Case Date ordering
        if (orderingType == BalanceOrderingTypeEnum.date 
          && balance.date.isAfter(aux.elementAt(i).date) 
        ) break;
        // Case Quantity ordering
        if (orderingType == BalanceOrderingTypeEnum.quantity 
          && balance.quantity > aux.elementAt(i).quantity 
        ) break;
        // Case Name ordering
        if (orderingType == BalanceOrderingTypeEnum.name 
          && balance.name.compareTo(aux.elementAt(i).name) < 0 
        ) break;
        i++;
      }
      aux.insert(i, balance);
    }
    if (limitType != BalanceLimitTypeEnum.none) {
      if (limitType == BalanceLimitTypeEnum.limit5) {
        aux = aux.take(5).toList();
      } else if (limitType == BalanceLimitTypeEnum.limit15) {
        aux = aux.take(15).toList();
      }
    }
    return aux;
  }
}