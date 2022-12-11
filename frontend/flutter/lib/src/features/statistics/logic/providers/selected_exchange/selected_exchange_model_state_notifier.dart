import 'package:balance_home_app/src/features/statistics/data/models/selected_exchange_model.dart';
import 'package:balance_home_app/src/features/statistics/logic/providers/selected_exchange/selected_exchange_model_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedExchangeModelStateNotifier extends StateNotifier<SelectedExchangeModelState> {
  SelectedExchangeModelStateNotifier() : 
    super(
      const SelectedExchangeModelState(
        SelectedExchangeModel(
          selectedCoinFrom: "EUR", 
          selectedCoinTo: "USD"
        )
      ));
  
  void setSelectedExchangeModel(SelectedExchangeModel model) {
    state = state.copyWith(model: model);
  }
  
  void setSelectedCoinFrom(String selectedCoinFrom) {
    SelectedExchangeModel model = SelectedExchangeModel(
      selectedCoinFrom: selectedCoinFrom,
      selectedCoinTo: state.model.selectedCoinTo
    ); 
    state = state.copyWith(model: model);
  }
  
  void setSelectedCoinTo(String selectedCoinTo) {
    SelectedExchangeModel model = SelectedExchangeModel(
      selectedCoinFrom: state.model.selectedCoinFrom,
      selectedCoinTo: selectedCoinTo
    ); 
    state = state.copyWith(model: model);
  }
  
  SelectedExchangeModel? getSelectedExchangeModel() {
    return state.model;
  }
}