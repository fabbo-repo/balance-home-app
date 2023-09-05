import 'package:balance_home_app/config/app_theme.dart';
import 'package:balance_home_app/src/core/application/app_version_controller.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/clients/local_db_client.dart';
import 'package:balance_home_app/src/core/clients/local_preferences_client.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/repositories/app_info_repository_interface.dart';
import 'package:balance_home_app/src/core/infrastructure/datasources/remote/app_version_remote_data_source.dart';
import 'package:balance_home_app/src/core/infrastructure/repositories/app_info_repository.dart';
import 'package:balance_home_app/src/core/presentation/models/app_version.dart';
import 'package:balance_home_app/src/core/presentation/states/app_localizations_state.dart';
import 'package:balance_home_app/src/core/presentation/states/theme_data_state.dart';
import 'package:balance_home_app/src/features/account/infrastructure/datasources/local/account_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_local_data_source.dart';
import 'package:balance_home_app/src/features/balance/infrastructure/datasources/local/balance_type_local_data_source.dart';
import 'package:balance_home_app/src/features/currency/infrastructure/datasources/local/currency_type_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/annual_balance_local_data_source.dart';
import 'package:balance_home_app/src/features/statistics/infrastructure/datasources/local/monthly_balance_local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:fpdart/fpdart.dart';
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

final appInfoRepositoryProvider = Provider<AppInfoRepositoryInterface>((ref) {
  return AppInfoRepository(
      appVersionRemoteDataSource:
          AppVersionRemoteDataSource(apiClient: ref.read(apiClientProvider)));
});

///
/// Application dependencies
///

final appVersionController = StateNotifierProvider<AppVersionController,
    AsyncValue<Either<Failure, AppVersion>>>((ref) {
  final repo = ref.read(appInfoRepositoryProvider);
  return AppVersionController(repository: repo);
});

///
/// Presentation dependencies
///

final themeDataProvider =
    StateNotifierProvider<ThemeDataState, ThemeData>((ref) {
  final theme =
      (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.light)
          ? AppTheme.lightTheme
          : AppTheme.darkTheme;
  return ThemeDataState(theme);
});

final appLocalizationsProvider =
    StateNotifierProvider<AppLocalizationsState, AppLocalizations>((_) {
  Locale locale = Locale(Platform.localeName.substring(0, 2));
  // If system's locale is not supported, Enlish will be used as default
  if (!AppLocalizations.supportedLocales.contains(locale)) {
    locale = const Locale("en");
  }
  return AppLocalizationsState(lookupAppLocalizations(locale));
});
