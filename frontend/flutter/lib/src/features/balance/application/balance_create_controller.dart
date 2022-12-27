import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_repository_interface.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_date.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_description.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceCreateController
    extends StateNotifier<AsyncValue<BalanceEntity?>> {
  final BalanceRepositoryInterface _repository;
  final BalanceTypeMode _balanceTypeMode;

  BalanceCreateController(this._repository, this._balanceTypeMode)
      : super(const AsyncValue.data(null));

  Future<void> handle(
      BalanceName name,
      BalanceDescription description,
      BalanceQuantity quantity,
      BalanceDate date,
      String coinType,
      BalanceTypeEntity balanceType) async {
    state = const AsyncValue.loading();
    state = await name.value
        .fold((l) => AsyncValue.error(l.error, StackTrace.empty),
            (name) async {
      return await description.value
          .fold((l) => AsyncValue.error(l.error, StackTrace.empty),
              (description) async {
        return await quantity.value
            .fold((l) => AsyncValue.error(l.error, StackTrace.empty),
                (quantity) async {
          return await date.value
              .fold((l) => AsyncValue.error(l.error, StackTrace.empty),
                  (date) async {
            final res = await _repository.createBalance(
                BalanceEntity(
                    id: null,
                    name: name,
                    description: description,
                    quantity: quantity,
                    date: date,
                    coinType: coinType,
                    balanceType: balanceType),
                _balanceTypeMode);
            return res.fold(
                (l) => AsyncValue.error(l.error, StackTrace.empty),
                AsyncValue.data);
          });
        });
      });
    });
  }
}
