import 'package:balance_home_app/providers/auth_providers/states/login_state.dart';
import 'package:balance_home_app/repository/auth_repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends StateNotifier<LoginState> {
  final Ref ref;
  
  LoginController(this.ref) : super(const LoginStateInitial());

  void login(String email, String password) async {
    state = const LoginStateLoading();
    try {
      await ref.read(authRepositoryProvider).login(
        email, password);
      state = const LoginStateSuccess();
    } catch (e) {
      state = LoginStateError(e.toString());
    }
  }
}

final loginControllerProvider = StateNotifierProvider<LoginController, LoginState>(
  (ref) {
    return LoginController(ref);
  }
);