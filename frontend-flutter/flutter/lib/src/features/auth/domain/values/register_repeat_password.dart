import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// User Repeat Password value
class UserRepeatPassword extends ValueAbstract<String> {
  @override
  Either<Failure, String> get value => _value;
  final Either<Failure, String> _value;

  factory UserRepeatPassword(
      AppLocalizations appLocalizations, String input1, String input2) {
    return UserRepeatPassword._(
      _validate(appLocalizations, input1, input2),
    );
  }

  const UserRepeatPassword._(this._value);
}

/// * minLength: 1
/// * [input1] == [input2]
Either<Failure, String> _validate(
    AppLocalizations appLocalizations, String input1, String input2) {
  if (input2.isNotEmpty && input1 == input2) {
    return right(input2);
  }
  String message = input2.isEmpty
      ? appLocalizations.needRepeatedPassword
      : appLocalizations.passwordNotMatch;
  return left(
    UnprocessableEntityFailure(
      detail: message,
    ),
  );
}
