import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/email_code_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/repositories/email_code_repository_interface.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
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
      state = AsyncValue.error(failure.error, StackTrace.empty);
      return left(failure);
    }, (email) async {
      final res = await _repository.requestCode(email);
      return res.fold((failure) {
        state = AsyncValue.error(failure.error, StackTrace.empty);
        String error = failure.error.toLowerCase();
        if (error.startsWith("email") && error.contains("user not found")) {
          return left(UnprocessableEntityFailure(
              message: appLocalizations.emailNotValid));
        }
        return left(UnprocessableEntityFailure(
            message: appLocalizations.errorSendingEmailCode));
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
      state = AsyncValue.error(failure.error, StackTrace.empty);
      return left(failure);
    }, (email) async {
      return await code.value.fold((failure) {
        state = AsyncValue.error(failure.error, StackTrace.empty);
        return left(failure);
      }, (code) async {
        final res = await _repository
            .verifyCode(EmailCodeEntity(email: email, code: code));
        return res.fold((failure) {
          state = AsyncValue.error(failure.error, StackTrace.empty);
          String error = failure.error.toLowerCase();
          if (error.startsWith("code") && error.contains("invalid code")) {
            return left(UnprocessableEntityFailure(
                message: appLocalizations.invalidEmailCode));
          } else if (error.startsWith("code") &&
              error.contains("code is no longer valid")) {
            return left(UnprocessableEntityFailure(
                message: appLocalizations.noLongerValidEmailCode));
          }
          return left(UnprocessableEntityFailure(
              message: appLocalizations.errorVerifyingEmailCode));
        }, (_) {
          state = const AsyncValue.data(null);
          return right(true);
        });
      });
    });
  }
}
