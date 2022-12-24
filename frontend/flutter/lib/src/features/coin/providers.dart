import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/coin_type_repository_interface.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/exchange_repository_interface.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/repositories/coin_type_repository.dart';
import 'package:balance_home_app/src/features/coin/infrastructure/repositories/exchange_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Infrastructure dependencies
///

/// Coin type repository
final coinTypeRepositoryProvider = Provider<CoinTypeRepositoryInterface>(
    (ref) => CoinTypeRepository(httpService: ref.read(httpServiceProvider)));

/// Exchange repository
final exchangeRepositoryProvider = Provider<ExchangeRepositoryInterface>(
    (ref) => ExchangeRepository(httpService: ref.read(httpServiceProvider)));
