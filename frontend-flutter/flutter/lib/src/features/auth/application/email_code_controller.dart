import 'package:balance_home_app/src/core/domain/failures/api_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/input_bad_request_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/email_code_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/email_code_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/values/email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/verification_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EmailCodeController extends StateNotifier<AsyncValue<void>> {
  final EmailCodeRepositoryInterface _repository;

  EmailCodeController(this._repository) : super(const AsyncValue.data(null));

  Future<Either<Failure, bool>> requestCode(
      UserEmail email, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await email.value.fold((failure) {
      state = AsyncValue.error(failure.detail, StackTrace.empty);
      return left(UnprocessableEntityFailure(detail: failure.detail));
    }, (email) async {
      final res = await _repository.requestCode(email);
      return res.fold((failure) {
        if (failure is ApiBadRequestFailure) {
          state = AsyncValue.error(failure.detail, StackTrace.empty);
          return left(UnprocessableEntityFailure(detail: failure.detail));
        } else if (failure is InputBadRequestFailure &&
            failure.containsFieldName("email")) {
          state = AsyncValue.error(
              appLocalizations.emailNotValid, StackTrace.empty);
          return left(UnprocessableEntityFailure(
              detail: appLocalizations.emailNotValid));
        }
        state = AsyncValue.error(
            appLocalizations.errorSendingEmailCode, StackTrace.empty);
        return left(UnprocessableEntityFailure(
            detail: appLocalizations.errorSendingEmailCode));
      }, (_) {
        state = const AsyncValue.data(null);
        return right(true);
      });
    });
  }

  Future<Either<Failure, bool>> verifyCode(UserEmail email,
      VerificationCode code, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await email.value.fold((failure) {
      state = AsyncValue.error(failure.detail, StackTrace.empty);
      return left(failure);
    }, (email) async {
      return await code.value.fold((failure) {
        state = AsyncValue.error(failure.detail, StackTrace.empty);
        return left(UnprocessableEntityFailure(detail: failure.detail));
      }, (code) async {
        final res = await _repository
            .verifyCode(EmailCodeEntity(email: email, code: code));
        return res.fold((failure) {
          if (failure is ApiBadRequestFailure) {
            state = AsyncValue.error(failure.detail, StackTrace.empty);
            return left(UnprocessableEntityFailure(detail: failure.detail));
          } else if (failure is InputBadRequestFailure &&
              failure.containsFieldName("code")) {
            state = AsyncValue.error(
                appLocalizations.invalidEmailCode, StackTrace.empty);
            return left(UnprocessableEntityFailure(
                detail: appLocalizations.invalidEmailCode));
          }
          state = AsyncValue.error(
              appLocalizations.errorVerifyingEmailCode, StackTrace.empty);
          return left(UnprocessableEntityFailure(
              detail: appLocalizations.errorVerifyingEmailCode));
        }, (_) {
          state = const AsyncValue.data(null);
          return right(true);
        });
      });
    });
  }
}
