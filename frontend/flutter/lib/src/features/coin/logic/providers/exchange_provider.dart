
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/coin/data/repositories/exchange_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository
final exchangeRepositoryProvider = Provider<IExchangeRepository>(
  (ProviderRef<IExchangeRepository> ref) => ExchangeRepository(
    httpService: ref.read(httpServiceProvider)
  )
);