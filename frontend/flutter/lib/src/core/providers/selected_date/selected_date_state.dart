import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_date_state.freezed.dart';

@freezed
class SelectedDateState with _$SelectedDateState {
  const factory SelectedDateState(SelectedDate date) = _SelectedDateState;
}