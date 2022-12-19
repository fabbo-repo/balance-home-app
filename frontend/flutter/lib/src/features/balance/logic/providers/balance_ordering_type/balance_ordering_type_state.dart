import 'package:balance_home_app/src/features/balance/data/models/balance_ordering_type_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_ordering_type_state.freezed.dart';

@freezed
class BalanceOrderingTypeState with _$BalanceOrderingTypeState {
  const factory BalanceOrderingTypeState(BalanceOrderingTypeEnum orderingType) = _BalanceOrderingTypeState;
}