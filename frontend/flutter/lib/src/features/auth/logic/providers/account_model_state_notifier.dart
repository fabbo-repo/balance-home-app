import 'package:balance_home_app/src/features/auth/data/models/account_model.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/account_model_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountModelStateNotifier extends StateNotifier<AccountModelState> {
  AccountModelStateNotifier() : super(AccountModelState(null));
  
  void setAccountModel(AccountModel account) {
    state = state.copyWith(model: account);
  }

  AccountModel? getAccountModel() {
    return state.model;
  }
}