import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Verification Code value
class VerificationCode extends ValueAbstract<String> {
  @override
  Either<Failure, String> get value => _value;
  final Either<Failure, String> _value;

  factory VerificationCode(AppLocalizations appLocalizations, String input) {
    return VerificationCode._(
      _validate(appLocalizations, input),
    );
  }

  const VerificationCode._(this._value);
}

/// * regex: [a-zA-Z0-9]{6}
Either<Failure, String> _validate(
    AppLocalizations appLocalizations, String input) {
  if (RegExp(r"^[a-zA-Z0-9]{6}").hasMatch(input)) {
    return right(input);
  }
  String message = appLocalizations.invalidCode;
  return left(
    UnprocessableEntityFailure(
      detail: message,
    ),
  );
}
