import 'package:balance_home_app/src/features/login/data/repositories/login_repository.dart';
import 'package:balance_home_app/src/features/login/logic/login_state.dart';
import 'package:balance_home_app/src/features/login/logic/login_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier
final loginStateNotifierProvider = StateNotifierProvider<LoginStateNotifier, LoginState>(
  (ref) => LoginStateNotifier(
    loginRepository: ref.watch(_loginRepositoryProvider)
  )
);


/// Repository
final _loginRepositoryProvider = Provider<ILoginRepository>(
  (ref) => LoginRepository()
);