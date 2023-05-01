import 'package:balance_home_app/config/providers.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/application/auth_controller.dart';
import 'package:balance_home_app/src/features/auth/application/email_code_controller.dart';
import 'package:balance_home_app/src/features/auth/application/reset_password_controller.dart';
import 'package:balance_home_app/src/features/auth/application/settings_controller.dart';
import 'package:balance_home_app/src/features/auth/application/user_edit_controller.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/email_code_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/reset_password_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/settings_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/jwt_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/local/theme_local_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/email_code_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/jwt_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/reset_password_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/datasources/remote/user_remote_data_source.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/auth_repository.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/email_code_repository.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/reset_password_repository.dart';
import 'package:balance_home_app/src/features/auth/infrastructure/repositories/settings_repository.dart';
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
          futureSharedPreferences: ref.read(sharedPreferencesProvider.future)),
      userRemoteDataSource:
          UserRemoteDataSource(apiClient: ref.read(apiClientProvider)));
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

final settingsRepositoryProvider = Provider<SettingsRepositoryInterface>((ref) {
  return SettingsRepository(
    themeLocalDataSource: ThemeLocalDataSource(
        futureSharedPreferences: ref.read(sharedPreferencesProvider.future)),
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
  final authRepo = ref.watch(authRepositoryProvider);
  final currencyConversionRepo =
      ref.watch(currencyConversionRepositoryProvider);
  return UserEditController(
      authRepository: authRepo,
      currencyConversionRepository: currencyConversionRepo);
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AsyncValue<void>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return SettingsController(authRepo, settingsRepo);
});
