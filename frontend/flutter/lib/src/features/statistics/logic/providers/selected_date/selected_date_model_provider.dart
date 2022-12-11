import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_state.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_date/selected_date_model_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedBalanceDateStateNotifierProvider = StateNotifierProvider<SelectedDateModelStateNotifier, SelectedDateModelState>(
  (StateNotifierProviderRef<SelectedDateModelStateNotifier, SelectedDateModelState> ref) => 
    SelectedDateModelStateNotifier()
);

final selectedSavingsDateStateNotifierProvider = StateNotifierProvider<SelectedDateModelStateNotifier, SelectedDateModelState>(
  (StateNotifierProviderRef<SelectedDateModelStateNotifier, SelectedDateModelState> ref) => 
    SelectedDateModelStateNotifier()
);