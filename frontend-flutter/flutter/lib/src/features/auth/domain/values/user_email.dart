import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// User Email value
class UserEmail extends ValueAbstract<String> {
  @override
  Either<Failure, String> get value => _value;
  final Either<Failure, String> _value;

  factory UserEmail(AppLocalizations appLocalizations, String input) {
    return UserEmail._(
      _validate(appLocalizations, input),
    );
  }

  const UserEmail._(this._value);
}

/// * minLength: 1
/// * valid email regex
Either<Failure, String> _validate(
    AppLocalizations appLocalizations, String input) {
  if (input.isNotEmpty &&
      RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(input)) {
    return right(input);
  }
  String message = input.isEmpty
      ? appLocalizations.needEmail
      : appLocalizations.emailNotValid;
  return left(
    UnprocessableEntityFailure(
      detail: message,
    ),
  );
}
