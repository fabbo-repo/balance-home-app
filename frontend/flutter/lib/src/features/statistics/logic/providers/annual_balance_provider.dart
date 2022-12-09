
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/statistics/data/repositories/annual_balance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Annual balance repository
final annualBalanceRepositoryProvider = Provider<IAnnualBalanceRepository>(
  (ProviderRef<IAnnualBalanceRepository> ref) => AnnualBalanceRepository(
    httpService: ref.read(httpServiceProvider)
  )
);