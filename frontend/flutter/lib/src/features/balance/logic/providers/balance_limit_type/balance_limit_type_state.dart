import 'package:balance_home_app/src/features/balance/data/models/balance_limit_type_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_limit_type_state.freezed.dart';

@freezed
class BalanceLimitTypeState with _$BalanceLimitTypeState {
  const factory BalanceLimitTypeState(BalanceLimitTypeEnum limitType) = _BalanceLimitTypeState;
}