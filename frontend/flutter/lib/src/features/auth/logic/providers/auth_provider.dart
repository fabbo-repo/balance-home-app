import 'package:balance_home_app/src/core/providers/http_service_provider.dart';
import 'package:balance_home_app/src/features/auth/data/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/account/account_model_state.dart';
import 'package:balance_home_app/src/features/auth/logic/providers/account/account_model_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier
final accountStateNotifierProvider = StateNotifierProvider<AccountModelStateNotifier, AccountModelState>(
  (StateNotifierProviderRef<AccountModelStateNotifier, AccountModelState> ref) => 
    AccountModelStateNotifier()
);

/// Repository
final authRepositoryProvider = Provider<IAuthRepository>(
  (ProviderRef<IAuthRepository> ref) => AuthRepository(
    httpService: ref.read(httpServiceProvider)
  )
);