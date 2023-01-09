import 'package:balance_home_app/src/core/domain/failures/failure.dart';
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

  Future<Either<Failure, UserEntity>> handle(
      UserEntity oldUser,
      UserName username,
      UserEmail email,
      BalanceQuantity expectedMonthlyBalance,
      BalanceQuantity expectedAnnualBalance,
      String prefCoinType,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await username.value.fold((l) {
      state = const AsyncValue.data(null);
      return left(l);
    }, (username) async {
      return await email.value.fold((l) {
        state = const AsyncValue.data(null);
        return left(l);
      }, (email) async {
        return await expectedMonthlyBalance.value.fold((l) {
          state = const AsyncValue.data(null);
          return left(l);
        }, (expectedMonthlyBalance) async {
          return await expectedAnnualBalance.value.fold((l) {
            state = const AsyncValue.data(null);
            return left(l);
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
            return res.fold((l) {
              state = const AsyncValue.data(null);
              String error = l.error.toLowerCase();
              if (error.startsWith("pref_coin_type") &&
                  error.contains("24 hours")) {
                return left(Failure.unprocessableEntity(
                    message: appLocalizations.userEditPrefCoinTypeError));
              } else if (error.startsWith("username") &&
                  error.contains("unique")) {
                return left(Failure.unprocessableEntity(
                    message: appLocalizations.usernameUsed));
              }
              return left(Failure.unprocessableEntity(
                  message: appLocalizations.genericError));
            }, (r) {
              state = const AsyncValue.data(null);
              return right(r);
            });
          });
        });
      });
    });
  }

  Future<Either<Failure, bool>> handleImage(Uint8List imageBytes,
      String imageType, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _authRepository.updateUserImage(imageBytes, imageType);
    return res.fold((l) {
      state = const AsyncValue.data(null);
      return left(Failure.unprocessableEntity(
          message: appLocalizations.userEditImageError));
    }, (r) {
      state = const AsyncValue.data(null);
      return right(r);
    });
  }

  Future<Either<Failure, double>> getExchange(double quantity, String coinFrom,
      String coinTo, AppLocalizations appLocalizations) async {
    return (await _exchangeRepository.getExchanges(coinFrom))
        .fold((l) => left(l), (r) {
      for (ExchangeEntity exchange in r.exchanges) {
        if (exchange.code == coinTo) {
          return right(
              ((quantity * exchange.value) * 100).roundToDouble() / 100.0);
        }
      }
      return left(
          Failure.unprocessableEntity(message: appLocalizations.genericError));
    });
  }
}
