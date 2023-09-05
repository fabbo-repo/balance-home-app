import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/input_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/features/account/domain/entities/account_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/values/email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/register_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:balance_home_app/src/features/currency/domain/entities/currency_conversion_entity.dart';
import 'package:balance_home_app/src/features/currency/domain/repositories/currency_conversion_repository_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserEditController extends StateNotifier<AsyncValue<void>> {
  final AuthRepositoryInterface authRepository;
  final CurrencyConversionRepositoryInterface currencyConversionRepository;

  UserEditController(
      {required this.authRepository,
      required this.currencyConversionRepository})
      : super(const AsyncValue.data(null));

  Future<Either<Failure, AccountEntity>> handle(
      AccountEntity oldUser,
      UserName username,
      UserEmail email,
      BalanceQuantity expectedMonthlyBalance,
      BalanceQuantity expectedAnnualBalance,
      String prefCurrencyType,
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
            final res = await authRepository.updateUser(
              AccountEntity(
                  username: username,
                  email: email,
                  receiveEmailBalance: oldUser.receiveEmailBalance,
                  balance: oldUser.balance,
                  expectedAnnualBalance: expectedAnnualBalance,
                  expectedMonthlyBalance: expectedMonthlyBalance,
                  language: oldUser.language,
                  prefCoinType: prefCurrencyType,
                  lastLogin: null,
                  image: null),
            );
            return res.fold((failure) {
              state = const AsyncValue.data(null);
              if (failure is ApiBadRequestFailure) {
                return left(UnprocessableEntityFailure(detail: failure.detail));
              } else if (failure is InputBadRequestFailure) {
                if (failure.containsFieldName("pref_currency_type")) {
                  return left(UnprocessableEntityFailure(
                      detail: appLocalizations.userEditPrefCurrencyTypeError));
                } else if (failure.containsFieldName("username")) {
                  return left(UnprocessableEntityFailure(
                      detail: appLocalizations.usernameUsed));
                }
              }
              return left(UnprocessableEntityFailure(
                  detail: appLocalizations.genericError));
            }, (value) {
              state = const AsyncValue.data(null);
              return right(value);
            });
          });
        });
      });
    });
  }

  Future<Either<Failure, void>> handleImage(Uint8List imageBytes,
      String imageType, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await authRepository.updateUserImage(imageBytes, imageType);
    return res.fold((_) {
      state = const AsyncValue.data(null);
      return left(UnprocessableEntityFailure(
          detail: appLocalizations.userEditImageError));
    }, (value) {
      state = const AsyncValue.data(null);
      return right(value);
    });
  }

  Future<Either<Failure, double>> getExchange(double quantity, String coinFrom,
      String coinTo, AppLocalizations appLocalizations) async {
    return (await currencyConversionRepository.getCurrencyConversion(coinFrom)).fold(
        (failure) => left(
            UnprocessableEntityFailure(detail: appLocalizations.genericError)),
        (value) {
      for (CurrencyConversionEntity conversion in value.exchanges) {
        if (conversion.code == coinTo) {
          return right(
              ((quantity * conversion.value) * 100).roundToDouble() / 100.0);
        }
      }
      return left(
          UnprocessableEntityFailure(detail: appLocalizations.genericError));
    });
  }
}
