
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/balance/data/repositories/balance_repository.dart';
import 'package:balance_home_app/src/features/balance/data/repositories/balance_type_respository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Balance type repository
final balanceTypeRepositoryProvider = Provider<IBalanceTypeRepository>(
  (ProviderRef<IBalanceTypeRepository> ref) => BalanceTypeRepository(
    httpService: ref.read(httpServiceProvider)
  )
);

/// Balance repository
final balanceRepositoryProvider = Provider<IBalanceRepository>(
  (ProviderRef<IBalanceRepository> ref) => BalanceRepository(
    httpService: ref.read(httpServiceProvider)
  )
);