import 'package:balance_home_app/src/core/domain/failures/bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/input_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/reset_password_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/reset_password_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_password.dart';
import 'package:balance_home_app/src/features/auth/domain/values/verification_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordController
    extends StateNotifier<AsyncValue<ResetPasswordProgress>> {
  final ResetPasswordRepositoryInterface _repository;

  ResetPasswordController(this._repository)
      : super(const AsyncValue.data(ResetPasswordProgress.none));

  void resetProgress() {
    state = const AsyncValue.data(ResetPasswordProgress.none);
  }

  Future<Either<UnprocessableEntityFailure, bool>> requestCode(
      UserEmail email, AppLocalizations appLocalizations,
      {bool retry = false}) async {
    state = const AsyncValue.loading();
    return await email.value.fold((failure) {
      state = !retry
          ? const AsyncValue.data(ResetPasswordProgress.none)
          : const AsyncValue.data(ResetPasswordProgress.started);
      return left(failure);
    }, (email) async {
      final res = await _repository.requestCode(email);
      return res.fold((failure) {
        state = !retry
            ? const AsyncValue.data(ResetPasswordProgress.none)
            : const AsyncValue.data(ResetPasswordProgress.started);
        if (failure is BadRequestFailure) {
          // TODO only three codes error_code appLocalizations.resetPasswordTooManyTries
          // TODO code has already been sent error_code appLocalizations.errorSendingCodeTime.replaceFirst("%%", error.split(" ")[8].split(".")[0])
          return left(UnprocessableEntityFailure(message: failure.detail));
        } else if (failure is InputBadRequestFailure) {
          if (failure.containsFieldName("email")) {
            return left(UnprocessableEntityFailure(
                message: appLocalizations.emailNotValid));
          } else if (failure.containsFieldName("inv_code")) {
            return left(UnprocessableEntityFailure(
                message: appLocalizations.invitationCodeNotValid));
          } else if (failure.containsFieldName("email")) {
            return left(UnprocessableEntityFailure(
                message: appLocalizations.emailUsed));
          } else if (failure.containsFieldName("username")) {
            return left(UnprocessableEntityFailure(
                message: appLocalizations.usernameUsed));
          }
        }
        return left(UnprocessableEntityFailure(
            message: appLocalizations.errorSendingCode));
      }, (_) {
        state = const AsyncValue.data(ResetPasswordProgress.started);
        return right(true);
      });
    });
  }

  Future<Either<UnprocessableEntityFailure, bool>> verifyCode(
      UserEmail email,
      VerificationCode code,
      UserPassword password,
      AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await email.value.fold((failure) {
      state = const AsyncValue.data(ResetPasswordProgress.started);
      return left(failure);
    }, (email) async {
      return await code.value.fold((failure) {
        state = const AsyncValue.data(ResetPasswordProgress.started);
        return left(failure);
      }, (code) async {
        return await password.value.fold((failure) {
          state = const AsyncValue.data(ResetPasswordProgress.started);
          return left(failure);
        }, (password) async {
          final res = await _repository.verifyCode(ResetPasswordEntity(
              email: email, newPassword: password, code: code));
          return res.fold((failure) {
            state = const AsyncValue.data(ResetPasswordProgress.started);

            if (failure is BadRequestFailure) {
              return left(UnprocessableEntityFailure(message: failure.detail));
            } else if (failure is InputBadRequestFailure) {
              if (failure.containsFieldName("new_password")) {
                return left(UnprocessableEntityFailure(
                    message: failure.getFieldDetail("new_password")));
              } else if (failure.containsFieldName("code")) {
                return left(UnprocessableEntityFailure(
                    message: failure.getFieldDetail("code")));
              }
            }
            return left(UnprocessableEntityFailure(
                message: appLocalizations.genericError));
          }, (_) {
            state = const AsyncValue.data(ResetPasswordProgress.verified);
            return right(true);
          });
        });
      });
    });
  }
}

enum ResetPasswordProgress { none, started, verified }
