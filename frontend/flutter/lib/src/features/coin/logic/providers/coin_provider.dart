
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/coin/data/repositories/coin_type_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repository
final coinTypeRepositoryProvider = Provider<ICoinTypeRepository>(
  (ProviderRef<ICoinTypeRepository> ref) => CoinTypeRepository(
    httpService: ref.read(httpServiceProvider)
  )
);