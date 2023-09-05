import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/presentation/models/balance_limit_type.dart';
import 'package:balance_home_app/src/features/balance/presentation/models/balance_ordering_type.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_create_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_card.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BalanceList extends ConsumerWidget {
  final BalanceTypeMode balanceTypeMode;
  final List<BalanceEntity> balances;

  const BalanceList(
      {required this.balances, required this.balanceTypeMode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = connectionStateListenable.value;
    final orderingType = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseOrderingTypeProvider)
        : ref.watch(revenueOrderingTypeProvider);
    final limitType = balanceTypeMode == BalanceTypeMode.expense
        ? ref.watch(expenseLimitTypeProvider)
        : ref.watch(revenueLimitTypeProvider);
    List<BalanceEntity> balanceList = orderBalances(orderingType, limitType);
    return Stack(children: <Widget>[
      ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: balanceList.length,
        itemBuilder: (BuildContext context, int index) {
          return BalanceCard(
              balance: balanceList[index], balanceTypeMode: balanceTypeMode);
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.bottomCenter,
        child: isConnected
            ? FloatingActionButton(
                onPressed: () async {
                  if (balanceTypeMode == BalanceTypeMode.expense) {
                    context.push(
                        "/${BalanceView.routeExpensePath}/${BalanceCreateView.routePath}");
                  } else {
                    context.push(
                        "/${BalanceView.routeRevenuePath}/${BalanceCreateView.routePath}");
                  }
                },
                backgroundColor: balanceTypeMode == BalanceTypeMode.expense
                    ? Colors.orange
                    : Colors.green,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    ]);
  }

  @visibleForTesting
  List<BalanceEntity> orderBalances(
      BalanceOrderingType orderingType, BalanceLimitType limitType) {
    List<BalanceEntity> aux = [];
    for (BalanceEntity balance in balances) {
      int i = 0;
      while (i < aux.length) {
        // Case Date ordering
        if (orderingType == BalanceOrderingType.date &&
            balance.date.isAfter(aux.elementAt(i).date)) break;
        // Case Quantity ordering
        if (orderingType == BalanceOrderingType.quantity &&
            balance.convertedQuantity! >
                aux.elementAt(i).convertedQuantity!) {
          break;
        }
        // Case Name ordering
        if (orderingType == BalanceOrderingType.name &&
            balance.name.compareTo(aux.elementAt(i).name) < 0) break;
        i++;
      }
      aux.insert(i, balance);
    }
    if (limitType != BalanceLimitType.none) {
      if (limitType == BalanceLimitType.limit5) {
        aux = aux.take(5).toList();
      } else if (limitType == BalanceLimitType.limit15) {
        aux = aux.take(15).toList();
      }
    }
    return aux;
  }
}
