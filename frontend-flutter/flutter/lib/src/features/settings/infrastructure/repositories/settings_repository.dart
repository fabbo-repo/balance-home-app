import 'package:balance_home_app/src/core/domain/failures/empty_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/settings/domain/repositories/settings_repository_interface.dart';
import 'package:balance_home_app/src/features/settings/infrastructure/datasources/local/theme_local_data_source.dart';
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
  Future<Either<Failure, bool>> saveTheme(ThemeData theme) async {
    return right(await themeLocalDataSource.store(theme));
  }

  @override
  Future<Either<Failure, ThemeData>> getTheme() async {
    final theme = await themeLocalDataSource.get();
    if (theme == null) return left(const EmptyFailure());
    return right(theme);
  }
}
