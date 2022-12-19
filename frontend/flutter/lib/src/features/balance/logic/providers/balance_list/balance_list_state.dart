import 'package:balance_home_app/src/features/balance/data/models/balance_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_list_state.freezed.dart';

@freezed
class BalanceListState with _$BalanceListState {
  const factory BalanceListState(List<BalanceModel> models) = _BalanceListState;
}