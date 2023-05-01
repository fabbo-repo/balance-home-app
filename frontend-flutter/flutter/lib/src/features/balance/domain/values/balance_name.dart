import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Balance Name value
class BalanceName extends ValueAbstract<String> {
  @override
  Either<Failure, String> get value => _value;
  final Either<Failure, String> _value;

  factory BalanceName(AppLocalizations appLocalizations, String input) {
    return BalanceName._(
      _validate(appLocalizations, input),
    );
  }

  const BalanceName._(this._value);
}

/// * minLength: 1
/// * maxLength: 40
Either<Failure, String> _validate(
    AppLocalizations appLocalizations, String input) {
  if (input.isNotEmpty && input.length <= 40) {
    return right(input);
  }
  String message = input.isEmpty
      ? appLocalizations.balanceNameRequired
      : appLocalizations.balanceNameMaxLength;
  return left(
    UnprocessableEntityFailure(
      detail: message,
    ),
  );
}
