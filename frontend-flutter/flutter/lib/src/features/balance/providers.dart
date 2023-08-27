import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date_mode.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/balance/application/balance_create_controller.dart';
import 'package:balance_home_app/src/features/balance/application/balance_edit_controller.dart';
import 'package:balance_home_app/src/features/balance/application/balance_list_controller.dart';
import 'package:balance_home_app/src/features/balance/application/balance_type_list_controller.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_respository_interface.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_type_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/remote/balance_remote_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/remote/balance_type_remote_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/repositories/balance_repository.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/repositories/balance_type_respository.dart';
import 'package:balance_home_app/src/features/balance/presentation/models/balance_limit_type.dart';
import 'package:balance_home_app/src/features/balance/presentation/models/balance_ordering_type.dart';
import 'package:balance_home_app/src/features/balance/presentation/states/balance_limit_type_state.dart';
import 'package:balance_home_app/src/features/balance/presentation/states/balance_ordering_type_state.dart';
import 'package:balance_home_app/src/core/presentation/states/selected_date_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

///
/// Infrastructure dependencies
///

/// Balance type repository
final balanceTypeRepositoryProvider = Provider<BalanceTypeRepositoryInterface>(
    (ref) => BalanceTypeRepository(
        balanceTypeRemoteDataSource:
            BalanceTypeRemoteDataSource(apiClient: ref.read(apiClientProvider)),
        balanceTypeLocalDataSource: BalanceTypeLocalDataSource(
            localDbClient: ref.read(localDbClientProvider))));

/// Balance repository
final balanceRepositoryProvider = Provider<BalanceRepositoryInterface>((ref) =>
    BalanceRepository(
        balanceRemoteDataSource:
            BalanceRemoteDataSource(apiClient: ref.read(apiClientProvider)),
        balanceLocalDataSource: BalanceLocalDataSource(
            localDbClient: ref.read(localDbClientProvider))));

///
/// Application dependencies
///
final revenueListControllerProvider = StateNotifierProvider<
    BalanceListController,
    AsyncValue<Either<Failure, List<BalanceEntity>>>>((ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  const balanceTypeMode = BalanceTypeMode.revenue;
  final selectedDate = ref.watch(revenueSelectedDateProvider);
  return BalanceListController(
      repository: repo,
      balanceTypeMode: balanceTypeMode,
      selectedDate: selectedDate);
});

final expenseListControllerProvider = StateNotifierProvider<
    BalanceListController,
    AsyncValue<Either<Failure, List<BalanceEntity>>>>((ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  const balanceTypeMode = BalanceTypeMode.expense;
  final selectedDate = ref.watch(expenseSelectedDateProvider);
  return BalanceListController(
      repository: repo,
      balanceTypeMode: balanceTypeMode,
      selectedDate: selectedDate);
});

final revenueCreateControllerProvider =
    StateNotifierProvider<BalanceCreateController, AsyncValue<BalanceEntity?>>(
        (ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  return BalanceCreateController(repo, BalanceTypeMode.revenue);
});

final expenseCreateControllerProvider =
    StateNotifierProvider<BalanceCreateController, AsyncValue<BalanceEntity?>>(
        (ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  return BalanceCreateController(repo, BalanceTypeMode.expense);
});

final revenueEditControllerProvider =
    StateNotifierProvider<BalanceEditController, AsyncValue<BalanceEntity?>>(
        (ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  return BalanceEditController(repo, BalanceTypeMode.revenue);
});

final expenseEditControllerProvider =
    StateNotifierProvider<BalanceEditController, AsyncValue<BalanceEntity?>>(
        (ref) {
  final repo = ref.watch(balanceRepositoryProvider);
  return BalanceEditController(repo, BalanceTypeMode.expense);
});

final revenueTypeListControllerProvider = StateNotifierProvider<
    BalanceTypeListController, AsyncValue<List<BalanceTypeEntity>>>((ref) {
  final repo = ref.watch(balanceTypeRepositoryProvider);
  const balanceTypeMode = BalanceTypeMode.revenue;
  return BalanceTypeListController(repo, balanceTypeMode);
});

final expenseTypeListControllerProvider = StateNotifierProvider<
    BalanceTypeListController, AsyncValue<List<BalanceTypeEntity>>>((ref) {
  final repo = ref.watch(balanceTypeRepositoryProvider);
  const balanceTypeMode = BalanceTypeMode.expense;
  return BalanceTypeListController(repo, balanceTypeMode);
});

///
/// Presentation dependencies
///

/// Limit type for revenues
final revenueLimitTypeProvider =
    StateNotifierProvider<BalanceLimitTypeState, BalanceLimitType>((ref) {
  return BalanceLimitTypeState(BalanceLimitType.limit15);
});

/// Limit type for expenses
final expenseLimitTypeProvider =
    StateNotifierProvider<BalanceLimitTypeState, BalanceLimitType>((ref) {
  return BalanceLimitTypeState(BalanceLimitType.limit15);
});

/// Ordering type for revenues
final revenueOrderingTypeProvider =
    StateNotifierProvider<BalanceOrderingTypeState, BalanceOrderingType>((ref) {
  return BalanceOrderingTypeState(BalanceOrderingType.date);
});

/// Ordering type for expenses
final expenseOrderingTypeProvider =
    StateNotifierProvider<BalanceOrderingTypeState, BalanceOrderingType>((ref) {
  return BalanceOrderingTypeState(BalanceOrderingType.date);
});

/// Selected date for revenues
final revenueSelectedDateProvider =
    StateNotifierProvider<SelectedDateState, SelectedDate>((ref) {
  return SelectedDateState(SelectedDateMode.month);
});

/// Selected date for expenses
final expenseSelectedDateProvider =
    StateNotifierProvider<SelectedDateState, SelectedDate>((ref) {
  return SelectedDateState(SelectedDateMode.month);
});
