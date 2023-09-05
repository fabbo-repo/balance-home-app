import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/application/auth_controller.dart';
import 'package:balance_home_app/src/features/auth/application/email_code_controller.dart';
import 'package:balance_home_app/src/features/auth/application/reset_password_controller.dart';
import 'package:balance_home_app/src/features/auth/application/user_edit_controller.dart';
import 'package:balance_home_app/src/features/account/domain/entities/account_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/email_code_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/reset_password_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/jwt_local_data_source.dart';
import 'package:balance_home_app/src/features/account/infrastructure/datasources/local/account_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/email_code_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/jwt_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/reset_password_remote_data_source.dart';
import 'package:balance_home_app/src/features/account/infrastructure/datasources/remote/account_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/email_code_repository.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/reset_password_repository.dart';
import 'package:balance_home_app/src/features/currency/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Infrastructure dependencies
///
final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  return AuthRepository(
      jwtRemoteDataSource:
          JwtRemoteDataSource(apiClient: ref.read(apiClientProvider)),
      jwtLocalDataSource: JwtLocalDataSource(
          storageClient: ref.read(localPreferencesClientProvider)),
      userRemoteDataSource:
          UserRemoteDataSource(apiClient: ref.read(apiClientProvider)),
      userLocalDataSource:
          UserLocalDataSource(localDbClient: ref.read(localDbClientProvider)));
});

final resetPasswordRepositoryProvider =
    Provider<ResetPasswordRepositoryInterface>((ref) {
  return ResetPasswordRepository(
    resetPasswordRemoteDataSource:
        ResetPasswordRemoteDataSource(apiClient: ref.read(apiClientProvider)),
  );
});

final emailCodeRepositoryProvider =
    Provider<EmailCodeRepositoryInterface>((ref) {
  return EmailCodeRepository(
    emailCodeRemoteDataSource:
        EmailCodeRemoteDataSource(apiClient: ref.read(apiClientProvider)),
  );
});

///
/// Application dependencies
///

/// Provides a [ValueNotifier] to the app router to redirect on auth state change
final authStateListenable = ValueNotifier<bool>(false);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AccountEntity?>>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return AuthController(repository: repo);
});

final resetPasswordControllerProvider = StateNotifierProvider<
    ResetPasswordController, AsyncValue<ResetPasswordProgress>>((ref) {
  final repo = ref.read(resetPasswordRepositoryProvider);
  return ResetPasswordController(repo);
});

final emailCodeControllerProvider =
    StateNotifierProvider<EmailCodeController, AsyncValue<void>>((ref) {
  final repo = ref.read(emailCodeRepositoryProvider);
  return EmailCodeController(repo);
});

final userEditControllerProvider =
    StateNotifierProvider<UserEditController, AsyncValue<void>>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  final currencyConversionRepo = ref.read(currencyConversionRepositoryProvider);
  return UserEditController(
      authRepository: authRepo,
      currencyConversionRepository: currencyConversionRepo);
});
