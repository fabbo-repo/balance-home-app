import 'package:balance_home_app/src/features/auth/data/models/account_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_model_state.freezed.dart';

@freezed
class AccountModelState with _$AccountModelState {
  const factory AccountModelState(AccountModel? model) = _AccountModelState;
}