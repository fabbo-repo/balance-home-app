import 'package:balance_home_app/src/core/infrastructure/datasources/selected_date_enum.dart';
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state.dart';
import 'package:balance_home_app/src/core/providers/selected_date/selected_date_state_notifier.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_limit_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/models/balance_ordering_type_enum.dart';
import 'package:balance_home_app/src/features/balance/data/repositories/balance_repository.dart';
import 'package:balance_home_app/src/features/balance/data/repositories/balance_type_respository.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_limit_type/balance_limit_type_state.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_limit_type/balance_limit_type_state_notifier.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_list/balance_list_state.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_list/balance_list_state_notifier.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_ordering_type/balance_ordering_type_state.dart';
import 'package:balance_home_app/src/features/balance/logic/providers/balance_ordering_type/balance_ordering_type_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Balance type repository
final balanceTypeRepositoryProvider = Provider<IBalanceTypeRepository>(
  (ProviderRef<IBalanceTypeRepository> ref) => BalanceTypeRepository(
    httpService: ref.read(httpServiceProvider)
  )
);

/// Balance repository
final balanceRepositoryProvider = Provider<IBalanceRepository>(
  (ProviderRef<IBalanceRepository> ref) => BalanceRepository(
    httpService: ref.read(httpServiceProvider)
  )
);

/// Revenue limit type
final revenueLimitTypeStateNotifierProvider = StateNotifierProvider<BalanceLimitTypeStateNotifier, BalanceLimitTypeState>(
  (StateNotifierProviderRef<BalanceLimitTypeStateNotifier, BalanceLimitTypeState> ref) => 
    BalanceLimitTypeStateNotifier(limitType: BalanceLimitTypeEnum.limit15)
);

/// Expense limit type
final expenseLimitTypeStateNotifierProvider = StateNotifierProvider<BalanceLimitTypeStateNotifier, BalanceLimitTypeState>(
  (StateNotifierProviderRef<BalanceLimitTypeStateNotifier, BalanceLimitTypeState> ref) => 
    BalanceLimitTypeStateNotifier(limitType: BalanceLimitTypeEnum.limit15)
);

/// Revenue list provider
final revenueListProvider = StateNotifierProvider<BalanceListStateNotifier, BalanceListState>(
  (StateNotifierProviderRef<BalanceListStateNotifier, BalanceListState> ref) => 
    BalanceListStateNotifier()
);

/// Expense list provider
final expenseListProvider = StateNotifierProvider<BalanceListStateNotifier, BalanceListState>(
  (StateNotifierProviderRef<BalanceListStateNotifier, BalanceListState> ref) => 
    BalanceListStateNotifier()
);

/// Revenue ordering type provider
final revenueOrderingTypeStateNotifierProvider = StateNotifierProvider<BalanceOrderingTypeStateNotifier, BalanceOrderingTypeState>(
  (StateNotifierProviderRef<BalanceOrderingTypeStateNotifier, BalanceOrderingTypeState> ref) => 
    BalanceOrderingTypeStateNotifier(orderingType: BalanceOrderingTypeEnum.date)
);

/// Expense ordering type provider
final expenseOrderingTypeStateNotifierProvider = StateNotifierProvider<BalanceOrderingTypeStateNotifier, BalanceOrderingTypeState>(
  (StateNotifierProviderRef<BalanceOrderingTypeStateNotifier, BalanceOrderingTypeState> ref) => 
    BalanceOrderingTypeStateNotifier(orderingType: BalanceOrderingTypeEnum.date)
);

/// Selected revenue date
final selectedRevenueDateStateNotifierProvider = StateNotifierProvider<SelectedDateStateNotifier, SelectedDateState>(
  (StateNotifierProviderRef<SelectedDateStateNotifier, SelectedDateState> ref) => 
    SelectedDateStateNotifier(selectedDateMode: SelectedDateEnum.month)
);

/// Selected expense date
final selectedExpenseDateStateNotifierProvider = StateNotifierProvider<SelectedDateStateNotifier, SelectedDateState>(
  (StateNotifierProviderRef<SelectedDateStateNotifier, SelectedDateState> ref) => 
    SelectedDateStateNotifier(selectedDateMode: SelectedDateEnum.month)
);