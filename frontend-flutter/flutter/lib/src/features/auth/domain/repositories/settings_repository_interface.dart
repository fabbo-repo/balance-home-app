import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

/// Settings Repository Interface.
abstract class SettingsRepositoryInterface {
  Future<Either<Failure, bool>> saveTheme(ThemeMode theme);

  Either<Failure, ThemeMode> getTheme();
}
