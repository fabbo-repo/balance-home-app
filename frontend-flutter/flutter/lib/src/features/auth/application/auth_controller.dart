import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/input_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unauthorized_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/credentials_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/register_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/failures/failure_constants.dart';
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
  @visibleForTesting
  final AuthRepositoryInterface repository;

  AuthController({required this.repository})
      : super(const AsyncValue.data(null));

  Future<Either<Failure, bool>> trySignIn() async {
    state = const AsyncValue.loading();
    final res = await repository.trySignIn();
    return await res.fold((failure) {
      state = const AsyncValue.data(null);
      return left(failure);
    }, (_) async {
      final res = await repository.getUser();
      return res.fold((failure) {
        state = const AsyncValue.data(null);
        return left(failure);
      }, (value) {
        state = AsyncValue.data(value);
        updateAuthState();
        return right(true);
      });
    });
  }

  Future<Either<Failure, void>> createUser(
      UserName username,
      UserEmail email,
      String language,
      InvitationCode invCode,
      String prefCurrencyType,
      UserPassword password,
      UserRepeatPassword password2,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await username.value.fold((failure) {
      state = const AsyncValue.data(null);
      return left(failure);
    }, (username) async {
      return await email.value.fold((failure) {
        state = const AsyncValue.data(null);
        return left(failure);
      }, (email) async {
        return await invCode.value.fold((failure) {
          state = const AsyncValue.data(null);
          return left(failure);
        }, (invCode) async {
          return await password.value.fold((failure) {
            state = const AsyncValue.data(null);
            return left(failure);
          }, (password) async {
            return await password2.value.fold((failure) {
              state = const AsyncValue.data(null);
              return left(failure);
            }, (password2) async {
              final res = await repository.createUser(RegisterEntity(
                  username: username,
                  email: email,
                  language: language,
                  invCode: invCode,
                  prefCoinType: prefCurrencyType,
                  password: password,
                  password2: password2));
              state = const AsyncValue.data(null);
              return res.fold((failure) {
                if (failure is ApiBadRequestFailure) {
                  return left(
                      UnprocessableEntityFailure(detail: failure.detail));
                } else if (failure is InputBadRequestFailure) {
                  if (failure.containsFieldName("password")) {
                    return left(UnprocessableEntityFailure(
                        detail: failure.getFieldDetail("password")));
                  } else if (failure.containsFieldName("inv_code")) {
                    return left(UnprocessableEntityFailure(
                        detail: appLocalizations.invitationCodeNotValid));
                  } else if (failure.containsFieldName("email")) {
                    return left(UnprocessableEntityFailure(
                        detail: appLocalizations.emailUsed));
                  } else if (failure.containsFieldName("username")) {
                    return left(UnprocessableEntityFailure(
                        detail: appLocalizations.usernameUsed));
                  }
                }
                return left(UnprocessableEntityFailure(
                    detail: appLocalizations.genericError));
              }, (value) => right(value));
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
    return email.value.fold((failure) {
      state = const AsyncValue.data(null);
      return left(failure);
    }, (email) async {
      return password.value.fold((failure) {
        state = const AsyncValue.data(null);
        return left(failure);
      }, (password) async {
        final res = await repository.signIn(
            CredentialsEntity(email: email, password: password),
            store: store);
        return res.fold((failure) {
          state = const AsyncValue.data(null);
          if (failure is ApiBadRequestFailure) {
            if (failure.errorCode == noInvCodeFailure) {
              return left(UnprocessableEntityFailure(
                  detail: appLocalizations.wrongCredentials));
            } else if (failure.errorCode == unverifiedEmailFailure) {
              return left(UnprocessableEntityFailure(
                  detail: appLocalizations.emailNotVerified));
            }
            return left(UnprocessableEntityFailure(detail: failure.detail));
          } else if (failure is InputBadRequestFailure) {
            if (failure.containsFieldName("email")) {
              return left(UnprocessableEntityFailure(
                  detail: appLocalizations.emailNotValid));
            }
          } else if (failure is UnauthorizedRequestFailure) {
            return left(UnprocessableEntityFailure(
                detail: appLocalizations.wrongCredentials));
          }
          return left(UnprocessableEntityFailure(
              detail: appLocalizations.genericError));
        }, (_) async {
          final res = await repository.getUser();
          return res.fold(
              (failure) => left(UnprocessableEntityFailure(
                  detail: appLocalizations.genericError)), (value) {
            state = AsyncValue.data(value);
            updateAuthState();
            return right(true);
          });
        });
      });
    });
  }

  /// Delete current user data
  Future<Either<Failure, void>> deleteUser() async {
    final res = await repository.deleteUser();
    if (res.isLeft()) return res;
    return await signOut();
  }

  /// Signs out user
  Future<Either<Failure, void>> signOut() async {
    final res = await repository.signOut();
    if (res.isLeft()) return res;
    state = const AsyncValue.data(null);
    updateAuthState();
    return right(null);
  }

  Future<Either<Failure, bool>> refreshUserData() async {
    state = const AsyncValue.loading();
    return await Future.delayed(const Duration(seconds: 2), () async {
      final res = await repository.getUser();
      return res.fold((failure) {
        return left(failure);
      }, (value) {
        state = AsyncValue.data(value);
        return right(true);
      });
    });
  }

  @visibleForTesting
  void updateAuthState() {
    authStateListenable.value = state.hasValue && state.asData!.value != null;
  }
}
