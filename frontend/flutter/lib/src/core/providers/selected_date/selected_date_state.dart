import 'package:balance_home_app/src/core/data/models/selected_date_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_date_state.freezed.dart';

@freezed
class SelectedDateState with _$SelectedDateState {
  const factory SelectedDateState(SelectedDateModel date) = _SelectedDateState;
}