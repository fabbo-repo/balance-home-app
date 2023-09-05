import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/features/account/domain/entities/account_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/settings/domain/repositories/settings_repository_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsController extends StateNotifier<AsyncValue<void>> {
  final AuthRepositoryInterface _authRepository;
  final SettingsRepositoryInterface _settingsRepository;

  SettingsController(this._authRepository, this._settingsRepository)
      : super(const AsyncValue.data(null));

  Future<Either<Failure, AccountEntity>> handleLanguage(AccountEntity oldUser,
      Locale lang, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _authRepository.updateUser(
      AccountEntity(
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
    return res.fold((_) {
      state = const AsyncValue.data(null);
      return left(
          UnprocessableEntityFailure(detail: appLocalizations.genericError));
    }, (value) {
      state = const AsyncValue.data(null);
      return right(value);
    });
  }

  Future<Either<Failure, AccountEntity>> handleReceiveEmailBalance(
      AccountEntity oldUser,
      bool receiveEmailBalance,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _authRepository.updateUser(
      AccountEntity(
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
    return res.fold((_) {
      state = const AsyncValue.data(null);
      return left(
          UnprocessableEntityFailure(detail: appLocalizations.genericError));
    }, (value) {
      state = const AsyncValue.data(null);
      return right(value);
    });
  }

  Future<Either<Failure, bool>> handleThemeMode(
      ThemeData theme, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _settingsRepository.saveTheme(theme);
    return res.fold((_) {
      state = const AsyncValue.data(null);
      return left(
          UnprocessableEntityFailure(detail: appLocalizations.genericError));
    }, (value) {
      state = const AsyncValue.data(null);
      return right(value);
    });
  }
}
