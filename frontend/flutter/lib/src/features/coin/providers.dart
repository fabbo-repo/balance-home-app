import 'package:balance_home_app/config/providers.dart';
import 'package:balance_home_app/src/features/coin/application/coin_type_list_controller.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/exchange_repository_interface.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/datasources/remote/coin_type_remote_data_source.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/datasources/remote/exchange_remote_data_source.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/repositories/coin_type_repository.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/repositories/exchange_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Application dependencies
///

final coinTypeListsControllerProvider = StateNotifierProvider<
    CoinTypeListController, AsyncValue<List<CoinTypeEntity>>>((ref) {
  final repo = ref.watch(coinTypeRepositoryProvider);
  return CoinTypeListController(repo);
});

///
/// Infrastructure dependencies
///

/// Coin type repository
final coinTypeRepositoryProvider = Provider<CoinTypeRepositoryInterface>(
    (ref) => CoinTypeRepository(
        coinTypeRemoteDataSource:
            CoinTypeRemoteDataSource(client: ref.read(httpClientProvider))));

/// Exchange repository
final exchangeRepositoryProvider = Provider<ExchangeRepositoryInterface>(
    (ref) => ExchangeRepository(
        exchangeRemoteDataSource:
            ExchangeRemoteDataSource(client: ref.read(httpClientProvider))));
