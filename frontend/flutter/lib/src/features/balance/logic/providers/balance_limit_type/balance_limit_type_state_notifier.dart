import 'package:balance_home_app/src/features/balance/data/models/balance_limit_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_limit_type/balance_limit_type_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceLimitTypeStateNotifier extends StateNotifier<BalanceLimitTypeState> {
  BalanceLimitTypeStateNotifier({BalanceLimitTypeEnum? limitType}) : 
    super(
      BalanceLimitTypeState(
        limitType ?? BalanceLimitTypeEnum.limit15
      ));

  void setLimitType(BalanceLimitTypeEnum limitType) {
    state = state.copyWith(limitType: limitType);
  }
}