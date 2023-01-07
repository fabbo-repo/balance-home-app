import 'package:balance_home_app/config/providers.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/application/auth_controller.dart';
import 'package:balance_home_app/src/features/auth/application/email_code_controller.dart';
import 'package:balance_home_app/src/features/auth/application/reset_password_controller.dart';
import 'package:balance_home_app/src/features/auth/application/user_edit_controller.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/email_code_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/reset_password_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/credentials_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/jwt_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/email_code_repository.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/reset_password_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///
/// Infrastructure dependencies
///
final authRepositoryProvider = Provider<AuthRepositoryInterface>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(
    httpService: httpService,
    credentialsLocalDataSource: CredentialsLocalDataSource(secureStorage),
    jwtLocalDataSource: JwtLocalDataSource(secureStorage),
  );
});

final resetPasswordRepositoryProvider =
    Provider<ResetPasswordRepositoryInterface>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return ResetPasswordRepository(
    httpService: httpService,
  );
});

final emailCodeRepositoryProvider =
    Provider<EmailCodeRepositoryInterface>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return EmailCodeRepository(
    httpService: httpService,
  );
});

///
/// Application dependencies
///

/// Provides a [ValueNotifier] to the app router to redirect on auth state change
final authStateListenable = ValueNotifier<bool>(false);

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final appLocalizationsState = ref.read(appLocalizationsProvider.notifier);
  return AuthController(repo, appLocalizationsState);
});

final resetPasswordControllerProvider = StateNotifierProvider<
    ResetPasswordController, AsyncValue<ResetPasswordProgress>>((ref) {
  final repo = ref.watch(resetPasswordRepositoryProvider);
  return ResetPasswordController(repo);
});

final emailCodeControllerProvider =
    StateNotifierProvider<EmailCodeController, AsyncValue<void>>((ref) {
  final repo = ref.watch(emailCodeRepositoryProvider);
  return EmailCodeController(repo);
});

final userEditControllerProvider =
    StateNotifierProvider<UserEditController, AsyncValue<void>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return UserEditController(repo);
});