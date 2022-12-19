import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedBalanceDateStateNotifierProvider = StateNotifierProvider<SelectedDateStateNotifier, SelectedDateState>(
  (StateNotifierProviderRef<SelectedDateStateNotifier, SelectedDateState> ref) => 
    SelectedDateStateNotifier()
);

final selectedSavingsDateStateNotifierProvider = StateNotifierProvider<SelectedDateStateNotifier, SelectedDateState>(
  (StateNotifierProviderRef<SelectedDateStateNotifier, SelectedDateState> ref) => 
    SelectedDateStateNotifier()
);