import 'package:balance_home_app/src/features/balance/data/models/balance_limit_type_enum.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_limit_type/balance_limit_type_state.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_limit_type/balance_limit_type_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final revenueLimitTypeStateNotifierProvider = StateNotifierProvider<BalanceLimitTypeStateNotifier, BalanceLimitTypeState>(
  (StateNotifierProviderRef<BalanceLimitTypeStateNotifier, BalanceLimitTypeState> ref) => 
    BalanceLimitTypeStateNotifier(limitType: BalanceLimitTypeEnum.limit15)
);