import 'package:balance_home_app/config/api_client.dart';
import 'package:balance_home_app/config/local_db_client.dart';
import 'package:balance_home_app/config/local_preferences_client.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/user_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_type_local_data_source.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/local/currency_type_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/annual_balance_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/monthly_balance_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:universal_io/io.dart';

///
/// Infrastructure dependencies
///

/// Exposes [LocalPreferencesClient] instance
final localPreferencesClientProvider =
    Provider((ref) => LocalPreferencesClient());

/// Exposes [LocalDbClient] instance
final localDbClientProvider =
    Provider((ref) => LocalDbClient(dbName: "balhomDb", tableNames: {
          UserLocalDataSource.tableName,
          BalanceTypeLocalDataSource.tableName,
          BalanceLocalDataSource.tableName,
          CurrencyTypeLocalDataSource.tableName,
          AnnualBalanceLocalDataSource.tableName,
          MonthlyBalanceLocalDataSource.tableName,
        }));

/// Exposes [HttpClient] instance
final apiClientProvider = Provider((ref) {
  return ApiClient();
});

/// Triggered from bootstrap() to complete futures
Future<void> initializeProviders(ProviderContainer container) async {
  usePathUrlStrategy();

  /// Core
  container.read(localPreferencesClientProvider);
  container.read(localDbClientProvider);
  container.read(apiClientProvider);
}
