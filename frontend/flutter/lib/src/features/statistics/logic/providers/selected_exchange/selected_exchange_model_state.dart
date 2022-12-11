import 'package:balance_home_app/src/features/statistics/data/models/selected_exchange_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_exchange_model_state.freezed.dart';

@freezed
class SelectedExchangeModelState with _$SelectedExchangeModelState {
  const factory SelectedExchangeModelState(SelectedExchangeModel model) = _SelectedExchangeModelState;
}