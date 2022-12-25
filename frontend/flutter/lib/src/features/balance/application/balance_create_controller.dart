import 'package:balance_home_app/src/core/application/utils.dart';
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
    if (name.value.isLeft()) {
      state = ControllerUtils.asyncError(name.value);
      return;
    }
    if (description.value.isLeft()) {
      state = ControllerUtils.asyncError(description.value);
      return;
    }
    if (quantity.value.isLeft()) {
      state = ControllerUtils.asyncError(quantity.value);
      return;
    }
    if (date.value.isLeft()) {
      state = ControllerUtils.asyncError(date.value);
      return;
    }
    final res = await _repository.createBalance(
        BalanceEntity(
            id: null,
            name: ControllerUtils.getRight(name.value, ""),
            description: ControllerUtils.getRight(description.value, ""),
            quantity: ControllerUtils.getRight(quantity.value, 0),
            date: ControllerUtils.getRight(date.value, DateTime.now()),
            coinType: coinType,
            balanceType: balanceType),
        _balanceTypeMode);
    state = res.fold(
        (l) => AsyncValue.error(l.error, StackTrace.fromString("")),
        AsyncValue.data);
  }
}
