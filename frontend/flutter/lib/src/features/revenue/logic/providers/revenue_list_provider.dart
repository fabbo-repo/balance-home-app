import 'package:balance_home_app/src/features/balance/logic/providers/balance_list/balance_list_state.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_list/balance_list_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Revenue list
final revenueListProvider = StateNotifierProvider<BalanceListStateNotifier, BalanceListState>(
  (StateNotifierProviderRef<BalanceListStateNotifier, BalanceListState> ref) => 
    BalanceListStateNotifier()
);