
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/revenue/data/repositories/revenue_repository.dart';
import 'package:balance_home_app/src/features/revenue/data/repositories/revenue_type_respository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Revenue type repository
final revenueTypeRepositoryProvider = Provider<IRevenueTypeRepository>(
  (ProviderRef<IRevenueTypeRepository> ref) => RevenueTypeRepository(
    httpService: ref.read(httpServiceProvider)
  )
);

/// Revenue repository
final revenueRepositoryProvider = Provider<IRevenueRepository>(
  (ProviderRef<IRevenueRepository> ref) => RevenueRepository(
    httpService: ref.read(httpServiceProvider)
  )
);