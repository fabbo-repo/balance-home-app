import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/presentation/states/app_localizations_state.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/values/invitation_code.dart';
import 'package:balance_home_app/src/features/auth/domain/values/login_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_name.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_repeat_password.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// State controller for authentication
class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepositoryInterface _repository;
  final AppLocalizationsState _appLocalizationsState;

  AuthController(this._repository, this._appLocalizationsState)
      : super(const AsyncValue.data(null)) {
    trySignIn();
  }

  Future<Either<Failure, bool>> trySignIn() async {
    state = const AsyncValue.loading();
    final res = await _repository.trySignIn();
    return res.fold((l) {
      state = const AsyncValue.data(null);
      return left(l);
    }, (r) async {
      final res = await _repository.getUser();
      return res.fold((l) {
        state = const AsyncValue.data(null);
        return left(l);
      }, (r) {
        state = AsyncValue.data(r);
        updateAuthState();
        updateAppLocaalizationsState();
        return right(true);
      });
    });
  }

  Future<Either<Failure, bool>> createUser(
      UserName username,
      UserEmail email,
      String language,
      InvitationCode invCode,
      String prefCoinType,
      UserPassword password,
      UserRepeatPassword password2,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await username.value.fold((l) {
      state = const AsyncValue.data(null);
      return left(l);
    }, (username) async {
      return await email.value.fold((l) {
        state = const AsyncValue.data(null);
        return left(l);
      }, (email) async {
        return await invCode.value.fold((l) {
          state = const AsyncValue.data(null);
          return left(l);
        }, (invCode) async {
          return await password.value.fold((l) {
            state = const AsyncValue.data(null);
            return left(l);
          }, (password) async {
            return await password2.value.fold((l) {
              state = const AsyncValue.data(null);
              return left(l);
            }, (password2) async {
              final res = await _repository.createUser(RegisterEntity(
                  username: username,
                  email: email,
                  language: language,
                  invCode: invCode,
                  prefCoinType: prefCoinType,
                  password: password,
                  password2: password2));
              state = const AsyncValue.data(null);
              return res.fold((l) {
                String error = l.error.toLowerCase();
                if (error.startsWith("password") &&
                    error.contains("too common")) {
                  return left(Failure.unprocessableEntity(
                      message: appLocalizations.tooCommonPassword));
                } else if (error.startsWith("inv_code")) {
                  return left(Failure.unprocessableEntity(
                      message: appLocalizations.invitationCodeNotValid));
                } else if (error.startsWith("email") &&
                    error.contains("unique")) {
                  return left(Failure.unprocessableEntity(
                      message: appLocalizations.emailUsed));
                } else if (error.startsWith("username") &&
                    error.contains("unique")) {
                  return left(Failure.unprocessableEntity(
                      message: appLocalizations.usernameUsed));
                }
                return left(Failure.unprocessableEntity(
                    message: appLocalizations.genericError));
              }, (r) => right(r));
            });
          });
        });
      });
    });
  }

  Future<Either<Failure, bool>> signIn(UserEmail email, LoginPassword password,
      AppLocalizations appLocalizations,
      {bool store = false}) async {
    state = const AsyncValue.loading();
    return email.value.fold((l) {
      state = const AsyncValue.data(null);
      return left(l);
    }, (email) async {
      return password.value.fold((l) {
        state = const AsyncValue.data(null);
        return left(l);
      }, (password) async {
        final res = await _repository.signIn(
            CredentialsEntity(email: email, password: password),
            store: store);
        return res.fold((l) {
          state = const AsyncValue.data(null);
          String error = l.error.toLowerCase();
          if (error.contains("no active account")) {
            return left(Failure.unprocessableEntity(
                message: appLocalizations.wrongCredentials));
          } else if (error.contains("unverified email")) {
            return left(Failure.unprocessableEntity(
                message: appLocalizations.emailNotVerified));
          }
          return left(Failure.unprocessableEntity(
              message: appLocalizations.genericError));
        }, (r) async {
          final res = await _repository.getUser();
          return res.fold((l) => left(l), (r) {
            state = AsyncValue.data(r);
            updateAuthState();
            updateAppLocaalizationsState();
            return right(true);
          });
        });
      });
    });
  }

  /// Delete current user data
  Future<Either<Failure, bool>> deleteUser() async {
    final res = await _repository.deleteUser();
    if (res.isLeft()) return res;
    state = const AsyncValue.data(null);
    updateAuthState();
    return right(true);
  }

  /// Signs out user
  Future<Either<Failure, bool>> signOut() async {
    final res = await _repository.signOut();
    if (res.isLeft()) return res;
    state = const AsyncValue.data(null);
    updateAuthState();
    return right(true);
  }

  Future<Either<Failure, bool>> refreshUserData() async {
    state = const AsyncValue.loading();
    return await Future.delayed(const Duration(seconds: 2), () async {
      final res = await _repository.getUser();
      return res.fold((l) {
        return left(l);
      }, (r) {
        state = AsyncValue.data(r);
        return right(true);
      });
    });
  }

  @visibleForTesting
  void updateAuthState() {
    authStateListenable.value = state.hasValue && state.asData!.value != null;
  }

  @visibleForTesting
  void updateAppLocaalizationsState() {
    _appLocalizationsState.setLocale(Locale(state.asData!.value!.language));
  }
}
