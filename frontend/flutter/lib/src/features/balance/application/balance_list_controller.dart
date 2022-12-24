import 'package:balance_home_app/src/core/presentation/models/selected_date.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceListController
    extends StateNotifier<AsyncValue<List<BalanceEntity>>> {
  final BalanceRepositoryInterface _repository;
  final BalanceTypeMode _balanceTypeMode;
  final SelectedDate _selectedDate;

  BalanceListController(
      this._repository, this._balanceTypeMode, this._selectedDate)
      : super(const AsyncValue.loading()) {
    getBalances();
  }

  Future<void> getBalances() async {
    final res = await _repository.getBalances(_balanceTypeMode,
        dateFrom: _selectedDate.dateFrom, dateTo: _selectedDate.dateTo);
    state = AsyncValue.data(res);
  }

  /// Add an entity to list
  void addBalance(BalanceEntity entity) {
    final items = state.value ?? [];
    state = const AsyncValue.loading();
    _repository.createBalance(entity, _balanceTypeMode);
    items.add(entity);
    state = AsyncValue.data(items);
  }

  /// Update an entity of the list
  void updateBalance(BalanceEntity entity) {
    final items = state.value ?? [];
    state = const AsyncValue.loading();
    final i = items.indexWhere((element) => element.id == entity.id);
    if (i != -1) {
      _repository.updateBalance(entity, _balanceTypeMode);
      items
        ..removeAt(i)
        ..insert(i, entity);
    }
    state = AsyncValue.data(items);
  }

  /// Delete an entity of the list
  void deleteBalance(BalanceEntity entity) {
    final items = state.value!;
    state = const AsyncValue.loading();
    _repository.deleteBalance(entity, _balanceTypeMode);
    items.remove(entity);
    state = AsyncValue.data(items);
  }
}
