import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/settings_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsController extends StateNotifier<AsyncValue<void>> {
  final AuthRepositoryInterface _authRepository;
  final SettingsRepositoryInterface _settingsRepository;

  SettingsController(this._authRepository, this._settingsRepository)
      : super(const AsyncValue.data(null));

  Future<Either<Failure, UserEntity>> handleLanguage(UserEntity oldUser,
      Locale lang, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _authRepository.updateUser(
      UserEntity(
          username: oldUser.username,
          email: oldUser.email,
          receiveEmailBalance: oldUser.receiveEmailBalance,
          balance: oldUser.balance,
          expectedAnnualBalance: oldUser.expectedAnnualBalance,
          expectedMonthlyBalance: oldUser.expectedMonthlyBalance,
          language: lang.languageCode,
          prefCoinType: oldUser.prefCoinType,
          lastLogin: null,
          image: null),
    );
    return res.fold((l) {
      state = const AsyncValue.data(null);
      return left(
          Failure.unprocessableEntity(message: appLocalizations.genericError));
    }, (r) {
      state = const AsyncValue.data(null);
      return right(r);
    });
  }

  Future<Either<Failure, UserEntity>> handleReceiveEmailBalance(
      UserEntity oldUser,
      bool receiveEmailBalance,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _authRepository.updateUser(
      UserEntity(
          username: oldUser.username,
          email: oldUser.email,
          receiveEmailBalance: receiveEmailBalance,
          balance: oldUser.balance,
          expectedAnnualBalance: oldUser.expectedAnnualBalance,
          expectedMonthlyBalance: oldUser.expectedMonthlyBalance,
          language: oldUser.language,
          prefCoinType: oldUser.prefCoinType,
          lastLogin: null,
          image: null),
    );
    return res.fold((l) {
      state = const AsyncValue.data(null);
      return left(
          Failure.unprocessableEntity(message: appLocalizations.genericError));
    }, (r) {
      state = const AsyncValue.data(null);
      return right(r);
    });
  }

  Future<Either<Failure, bool>> handleThemeMode(
      ThemeMode theme, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _settingsRepository.saveTheme(theme);
    return res.fold((l) {
      state = const AsyncValue.data(null);
      return left(
          Failure.unprocessableEntity(message: appLocalizations.genericError));
    }, (r) {
      state = const AsyncValue.data(null);
      return right(r);
    });
  }
}
