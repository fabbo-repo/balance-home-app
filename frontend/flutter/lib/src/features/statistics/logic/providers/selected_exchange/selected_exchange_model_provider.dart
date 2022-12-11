import 'package:balance_home_app/src/features/statistics/logic/providers/selected_exchange/selected_exchange_model_state.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_exchange/selected_exchange_model_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedExchangeStateNotifierProvider = StateNotifierProvider<SelectedExchangeModelStateNotifier, SelectedExchangeModelState>(
  (StateNotifierProviderRef<SelectedExchangeModelStateNotifier, SelectedExchangeModelState> ref) => 
    SelectedExchangeModelStateNotifier()
);