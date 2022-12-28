import 'package:balance_home_app/src/core/domain/failures/failure.dart';
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
    return await email.value.fold((l) {
      state = AsyncValue.error(l.error, StackTrace.empty);
      return left(l);
    }, (email) async {
      final res = await _repository.requestCode(email);
      return res.fold((l) {
        state = AsyncValue.error(l.error, StackTrace.empty);
        String error = l.error.toLowerCase();
        if (error.startsWith("email") && error.contains("user not found")) {
          return left(Failure.unprocessableEntity(
              message: appLocalizations.emailNotValid));
        }
        return left(Failure.unprocessableEntity(
            message: appLocalizations.errorSendingEmailCode));
      }, (r) {
        state = const AsyncValue.data(null);
        return right(true);
      });
    });
  }

  Future<Either<Failure, bool>> verifyCode(UserEmail email,
      VerificationCode code, AppLocalizations appLocalizations) async {
    state = const AsyncValue.loading();
    return await email.value.fold((l) {
      state = AsyncValue.error(l.error, StackTrace.empty);
      return left(l);
    }, (email) async {
      return await code.value.fold((l) {
        state = AsyncValue.error(l.error, StackTrace.empty);
        return left(l);
      }, (code) async {
        final res = await _repository
            .verifyCode(EmailCodeEntity(email: email, code: code));
        return res.fold((l) {
          state = AsyncValue.error(l.error, StackTrace.empty);
          String error = l.error.toLowerCase();
          if (error.startsWith("code") && error.contains("invalid code")) {
            return left(Failure.unprocessableEntity(
                message: appLocalizations.invalidEmailCode));
          } else if (error.startsWith("code") &&
              error.contains("code is no longer valid")) {
            return left(Failure.unprocessableEntity(
                message: appLocalizations.noLongerValidEmailCode));
          }
          return left(Failure.unprocessableEntity(
              message: appLocalizations.errorVerifyingEmailCode));
        }, (r) {
          state = const AsyncValue.data(null);
          return right(true);
        });
      });
    });
  }
}
