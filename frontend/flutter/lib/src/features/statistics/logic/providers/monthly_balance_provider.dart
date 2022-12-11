
import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/statistics/data/repositories/monthly_balance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Monthly balance repository
final monthlyBalanceRepositoryProvider = Provider<IMonthlyBalanceRepository>(
  (ProviderRef<IMonthlyBalanceRepository> ref) => MonthlyBalanceRepository(
    httpService: ref.read(httpServiceProvider)
  )
);