import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Login User Password value
class LoginPassword extends ValueAbstract<String> {
  @override
  Either<UnprocessableEntityFailure, String> get value => _value;
  final Either<UnprocessableEntityFailure, String> _value;

  factory LoginPassword(AppLocalizations appLocalizations, String input) {
    return LoginPassword._(
      _validate(appLocalizations, input),
    );
  }

  const LoginPassword._(this._value);
}

/// * minLength: 1
Either<UnprocessableEntityFailure, String> _validate(
    AppLocalizations appLocalizations, String input) {
  if (input.isNotEmpty) {
    return right(input);
  }
  return left(
    UnprocessableEntityFailure(
      message: appLocalizations.needPassword,
    ),
  );
}
