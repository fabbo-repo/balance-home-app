import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_list/balance_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceListStateNotifier extends StateNotifier<BalanceListState> {
  BalanceListStateNotifier() : 
    super(const BalanceListState([]));
  
  void setBalances(List<BalanceModel> models) {
    state = state.copyWith(models: models);
  }

  void addBalance(BalanceModel model) {
    List<BalanceModel> models = state.models..add(model);
    state = state.copyWith(models: models);
  }
  
  void removeBalance(BalanceModel model) {
    List<BalanceModel> models = state.models..remove(model);
    state = state.copyWith(models: models);
  }
}