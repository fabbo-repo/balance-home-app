import 'package:balance_home_app/config/providers.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/currency/application/currency_type_list_controller.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_type_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_conversion_repository_interface.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_type_repository_interface.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/local/currency_type_local_data_source.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/remote/currency_conversion_remote_data_source.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/remote/currency_type_remote_data_source.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/repositories/currency_conversion_repository.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/repositories/currency_type_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

///
/// Application dependencies
///

final currencyTypeListsControllerProvider = StateNotifierProvider<
    CurrencyTypeListController,
    AsyncValue<Either<Failure, List<CurrencyTypeEntity>>>>((ref) {
  final repo = ref.watch(currencyTypeRepositoryProvider);
  return CurrencyTypeListController(currencyTypeRepository: repo);
});

///
/// Infrastructure dependencies
///

/// Coin type repository
final currencyTypeRepositoryProvider =
    Provider<CurrencyTypeRepositoryInterface>((ref) => CurrencyTypeRepository(
        currencyTypeRemoteDataSource: CurrencyTypeRemoteDataSource(
            apiClient: ref.read(apiClientProvider)),
        currencyTypeLocalDataSource: CurrencyTypeLocalDataSource(
            localDbClient: ref.read(localDbClientProvider))));

/// Exchange repository
final currencyConversionRepositoryProvider =
    Provider<CurrencyConversionRepositoryInterface>((ref) =>
        CurrencyConversionRepository(
            currencyConversionRemoteDataSource:
                CurrencyConversionRemoteDataSource(
                    apiClient: ref.read(apiClientProvider))));
