import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

class BalanceListController
    extends StateNotifier<AsyncValue<Either<Failure, List<BalanceEntity>>>> {
  final BalanceRepositoryInterface repository;
  final BalanceTypeMode balanceTypeMode;
  final SelectedDate selectedDate;

  BalanceListController(
      {required this.repository,
      required this.balanceTypeMode,
      required this.selectedDate})
      : super(const AsyncValue.loading()) {
    getBalances();
  }

  Future<void> getBalances() async {
    final res = await repository.getBalances(balanceTypeMode,
        dateFrom: selectedDate.dateFrom, dateTo: selectedDate.dateTo);
    state = res.fold((failure) {
      if (failure is HttpConnectionFailure || failure is ApiBadRequestFailure) {
        return AsyncData(left(failure));
      }
      return AsyncValue.error(failure.detail, StackTrace.empty);
    }, (entities) {
      return AsyncValue.data(right(entities));
    });
  }

  /// Add an entity to list
  void addBalance(BalanceEntity entity) {
    // No need to use repository, 
    // it will be used by Create Controller
    if (state.value != null) {
      state.value!.fold((_) {}, (entities) {
        entities.add(entity);
        state = AsyncValue.data(right(entities));
      });
    } else {
      state = AsyncValue.data(right([entity]));
    }
  }

  /// Update an entity of the list
  void updateBalance(BalanceEntity entity) {
    // No need to use repository, 
    // it will be used by Edit Controller
    if (state.value != null) {
      state.value!.fold((_) {}, (entities) {
        final i = entities.indexWhere((element) => element.id == entity.id);
        if (i != -1) {
          entities
            ..removeAt(i)
            ..insert(i, entity);
        }
        state = AsyncValue.data(right(entities));
      });
    } else {
      state = AsyncValue.data(right([entity]));
    }
  }

  /// Delete an entity of the list
  void deleteBalance(BalanceEntity entity) {
    if (state.value != null) {
      state.value!.fold((_) {}, (entities) {
        entities.remove(entity);
        repository.deleteBalance(entity, balanceTypeMode);
        state = AsyncValue.data(right(entities));
      });
    }
  }

  /// Get a list of years of stored balances
  Future<List<int>> getAllBalanceYears() async {
    final res = await repository.getBalanceYears(balanceTypeMode);
    return res.fold((_) => [], (value) => value);
  }
}
