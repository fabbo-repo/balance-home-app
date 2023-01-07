import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_io/io.dart';

class UserEditController extends StateNotifier<AsyncValue<void>> {
  final AuthRepositoryInterface _repository;

  UserEditController(this._repository) : super(const AsyncValue.data(null));

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
            final res = await _repository.updateUser(
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

  Future<Either<Failure, bool>> handleImage(
      File image, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    final res = await _repository.updateUserImage(image);
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
