import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_respository_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceTypeListController
    extends StateNotifier<AsyncValue<List<BalanceTypeEntity>>> {
  final BalanceTypeRepositoryInterface _balanceTypeRepository;
  final BalanceTypeMode _balanceTypeMode;

  BalanceTypeListController(this._balanceTypeRepository, this._balanceTypeMode)
      : super(const AsyncValue.loading()) {
    handle();
  }

  @visibleForTesting
  Future<void> handle() async {
    final res = await _balanceTypeRepository.getBalanceTypes(_balanceTypeMode);
    state = res.fold(
        (failure) => AsyncValue.error(
            failure is ApiBadRequestFailure ? failure.detail : "",
            StackTrace.empty),
        (value) => AsyncData(value));
  }
}
