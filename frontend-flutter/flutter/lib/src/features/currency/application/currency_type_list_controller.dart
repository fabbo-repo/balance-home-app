import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_type_repository_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyTypeListController
    extends StateNotifier<AsyncValue<List<CurrencyTypeEntity>>> {
  final CurrencyTypeRepositoryInterface currencyTypeRepository;

  CurrencyTypeListController({required this.currencyTypeRepository})
      : super(const AsyncValue.loading()) {
    handle();
  }

  @visibleForTesting
  Future<void> handle() async {
    final res = await currencyTypeRepository.getCurrencyTypes();
    state = res.fold(
        (failure) => AsyncValue.error(
            failure is ApiBadRequestFailure ? failure.detail : "",
            StackTrace.empty),
        (value) => AsyncData(value));
  }
}
