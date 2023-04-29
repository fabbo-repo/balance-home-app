import 'package:balance_home_app/src/core/domain/failures/failure.dart';
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

  Future<Either<Failure, bool>> requestCode(
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
        String error = failure.error.toLowerCase();
        if (error.startsWith("email") && error.contains("user not found")) {
          return left(UnprocessableEntityFailure(
              message: appLocalizations.emailNotValid));
        }
        if (error.startsWith("count_pass_reset") &&
            error.contains("only three codes")) {
          return left(UnprocessableEntityFailure(
              message: appLocalizations.resetPasswordTooManyTries));
        } else if (error.startsWith("code") &&
            error.contains("code has already been sent")) {
          return left(UnprocessableEntityFailure(
              message: appLocalizations.errorSendingCodeTime
                  .replaceFirst("%%", error.split(" ")[8].split(".")[0])));
        }
        return left(UnprocessableEntityFailure(
            message: appLocalizations.errorSendingCode));
      }, (_) {
        state = const AsyncValue.data(ResetPasswordProgress.started);
        return right(true);
      });
    });
  }

  Future<Either<Failure, bool>> verifyCode(
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
            String error = failure.error.toLowerCase();
            if (error.startsWith("code") && error.contains("invalid code")) {
              return left(UnprocessableEntityFailure(
                  message: appLocalizations.invalidCode));
            } else if (error.startsWith("code") &&
                error.contains("code is no longer valid")) {
              return left(UnprocessableEntityFailure(
                  message: appLocalizations.noLongerValidCode));
            } else if (error.startsWith("new_password") &&
                error.contains("too common")) {
              return left(UnprocessableEntityFailure(
                  message: appLocalizations.tooCommonPassword));
            }
            return left(UnprocessableEntityFailure(
                message: appLocalizations.errorVerifyingCode));
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
