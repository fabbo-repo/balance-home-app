import 'package:balance_home_app/src/features/balance/data/models/balance_ordering_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_ordering_type/balance_ordering_type_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceOrderingTypeStateNotifier extends StateNotifier<BalanceOrderingTypeState> {
  BalanceOrderingTypeStateNotifier({BalanceOrderingTypeEnum? orderingType}) : 
    super(
      BalanceOrderingTypeState(
        orderingType ?? BalanceOrderingTypeEnum.date
      ));

  void setOrderingType(BalanceOrderingTypeEnum orderingType) {
    state = state.copyWith(orderingType: orderingType);
  }
}