import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/input_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/exchange_entity.dart';
import 'package:balance_home_app/src/features/coin/domain/repositories/exchange_repository_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserEditController extends StateNotifier<AsyncValue<void>> {
  final AuthRepositoryInterface _authRepository;
  final ExchangeRepositoryInterface _exchangeRepository;

  UserEditController(this._authRepository, this._exchangeRepository)
      : super(const AsyncValue.data(null));

  Future<Either<UnprocessableEntityFailure, UserEntity>> handle(
      UserEntity oldUser,
      UserName username,
      UserEmail email,
      BalanceQuantity expectedMonthlyBalance,
      BalanceQuantity expectedAnnualBalance,
      String prefCoinType,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await username.value.fold((failure) {
      state = const AsyncValue.data(null);
      return left(failure);
    }, (username) async {
      return await email.value.fold((failure) {
        state = const AsyncValue.data(null);
        return left(failure);
      }, (email) async {
        return await expectedMonthlyBalance.value.fold((failure) {
          state = const AsyncValue.data(null);
          return left(failure);
        }, (expectedMonthlyBalance) async {
          return await expectedAnnualBalance.value.fold((failure) {
            state = const AsyncValue.data(null);
            return left(failure);
          }, (expectedAnnualBalance) async {
            final res = await _authRepository.updateUser(
              UserEntity(
                  username: username,
                  email: email,
                  receiveEmailBalance: oldUser.receiveEmailBalance,
                  balance: oldUser.balance,
                  expectedAnnualBalance: expectedAnnualBalance,
                  expectedMonthlyBalance: expectedMonthlyBalance,
                  language: oldUser.language,
                  prefCoinType: prefCoinType,
                  lastLogin: null,
                  image: null),
            );
            return res.fold((failure) {
              state = const AsyncValue.data(null);
              if (failure is ApiBadRequestFailure) {
                return left(
                    UnprocessableEntityFailure(message: failure.detail));
              } else if (failure is InputBadRequestFailure) {
                if (failure.containsFieldName("pref_coin_type")) {
                  return left(UnprocessableEntityFailure(
                      message: appLocalizations.userEditPrefCoinTypeError));
                } else if (failure.containsFieldName("username")) {
                  return left(UnprocessableEntityFailure(
                      message: appLocalizations.usernameUsed));
                }
              }
              return left(UnprocessableEntityFailure(
                  message: appLocalizations.genericError));
            }, (value) {
              state = const AsyncValue.data(null);
              return right(value);
            });
          });
        });
      });
    });
  }

  Future<Either<UnprocessableEntityFailure, void>> handleImage(
      Uint8List imageBytes,
      String imageType,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _authRepository.updateUserImage(imageBytes, imageType);
    return res.fold((_) {
      state = const AsyncValue.data(null);
      return left(UnprocessableEntityFailure(
          message: appLocalizations.userEditImageError));
    }, (value) {
      state = const AsyncValue.data(null);
      return right(value);
    });
  }

  Future<Either<UnprocessableEntityFailure, double>> getExchange(
      double quantity,
      String coinFrom,
      String coinTo,
      AppLocalizations appLocalizations) async {
    return (await _exchangeRepository.getExchanges(coinFrom)).fold(
        (failure) => left(
            UnprocessableEntityFailure(message: appLocalizations.genericError)),
        (value) {
      for (ExchangeEntity exchange in value.exchanges) {
        if (exchange.code == coinTo) {
          return right(
              ((quantity * exchange.value) * 100).roundToDouble() / 100.0);
        }
      }
      return left(
          UnprocessableEntityFailure(message: appLocalizations.genericError));
    });
  }
}
