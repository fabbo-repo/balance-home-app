import 'package:balance_home_app/src/features/statistics/data/models/selected_date_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_date_model_state.freezed.dart';

@freezed
class SelectedDateModelState with _$SelectedDateModelState {
  const factory SelectedDateModelState(SelectedDateModel model) = _SelectedDateModelState;
}