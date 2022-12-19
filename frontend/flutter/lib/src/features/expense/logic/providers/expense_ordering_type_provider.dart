import 'package:balance_home_app/src/features/balance/data/models/balance_ordering_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_ordering_type/balance_ordering_type_state.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_ordering_type/balance_ordering_type_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseOrderingTypeStateNotifierProvider = StateNotifierProvider<BalanceOrderingTypeStateNotifier, BalanceOrderingTypeState>(
  (StateNotifierProviderRef<BalanceOrderingTypeStateNotifier, BalanceOrderingTypeState> ref) => 
    BalanceOrderingTypeStateNotifier(orderingType: BalanceOrderingTypeEnum.date)
);