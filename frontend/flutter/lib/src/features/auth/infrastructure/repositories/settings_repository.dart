import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/settings_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/theme_local_data_source.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// Settings Repository.
class SettingsRepository extends SettingsRepositoryInterface {
  final ThemeLocalDataSource themeLocalDataSource;

  /// Default constructor
  SettingsRepository({
    required this.themeLocalDataSource,
  });

  @override
  Future<Either<Failure, bool>> saveTheme(ThemeMode theme) async {
    return right(await themeLocalDataSource.store(theme));
  }

  @override
  Either<Failure, ThemeMode> getTheme() {
    return right(themeLocalDataSource.get());
  }
}
