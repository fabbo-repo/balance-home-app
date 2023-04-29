import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinTypeListController
    extends StateNotifier<AsyncValue<List<CoinTypeEntity>>> {
  final CoinTypeRepositoryInterface _coinTypeRepository;

  CoinTypeListController(this._coinTypeRepository)
      : super(const AsyncValue.loading()) {
    handle();
  }

  @visibleForTesting
  Future<void> handle() async {
    final res = await _coinTypeRepository.getCoinTypes();
    state = res.fold(
        (failure) => AsyncValue.error(
            failure is BadRequestFailure ? failure.detail : "",
            StackTrace.empty),
        (value) => AsyncData(value));
  }
}
