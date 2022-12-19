import 'package:balance_home_app/src/core/data/models/selected_date_enum.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedRevenueDateStateNotifierProvider = StateNotifierProvider<SelectedDateStateNotifier, SelectedDateState>(
  (StateNotifierProviderRef<SelectedDateStateNotifier, SelectedDateState> ref) => 
    SelectedDateStateNotifier(selectedDateMode: SelectedDateEnum.month)
);