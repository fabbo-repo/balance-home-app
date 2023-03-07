import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_date.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_description.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BalanceEditController extends StateNotifier<AsyncValue<BalanceEntity?>> {
  final BalanceRepositoryInterface _repository;
  final BalanceTypeMode _balanceTypeMode;

  BalanceEditController(this._repository, this._balanceTypeMode)
      : super(const AsyncValue.data(null));

  Future<Either<Failure, BalanceEntity>> handle(
      int id,
      BalanceName name,
      BalanceDescription description,
      BalanceQuantity quantity,
      BalanceDate date,
      String coinType,
      BalanceTypeEntity balanceType,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await name.value.fold((l) {
      state = const AsyncValue.data(null);
      return left(l);
    }, (name) async {
      return await description.value.fold((l) {
        state = const AsyncValue.data(null);
        return left(l);
      }, (description) async {
        return await quantity.value.fold((l) {
          state = const AsyncValue.data(null);
          return left(l);
        }, (quantity) async {
          return await date.value.fold((l) {
            state = const AsyncValue.data(null);
            return left(l);
          }, (date) async {
            final res = await _repository.updateBalance(
                BalanceEntity(
                    id: id,
                    name: name,
                    description: description,
                    real_quantity: quantity,
                    date: date,
                    coinType: coinType,
                    balanceType: balanceType,
                    converted_quantity: null),
                _balanceTypeMode);
            return res.fold((l) {
              state = const AsyncValue.data(null);
              return left(Failure.unprocessableEntity(
                  message: appLocalizations.genericError));
            }, (r) {
              state = AsyncValue.data(r);
              return right(r);
            });
          });
        });
      });
    });
  }
}
