import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Balance Description value
class BalanceDescription extends ValueAbstract<String> {
  @override
  Either<UnprocessableEntityFailure, String> get value => _value;
  final Either<UnprocessableEntityFailure, String> _value;

  factory BalanceDescription(AppLocalizations appLocalizations, String input) {
    return BalanceDescription._(
      _validate(appLocalizations, input),
    );
  }

  const BalanceDescription._(this._value);
}

/// * maxLength: 2000
Either<UnprocessableEntityFailure, String> _validate(
    AppLocalizations appLocalizations, String input) {
  if (input.length <= 2000) {
    return right(input);
  }
  return left(
    UnprocessableEntityFailure(
      message: appLocalizations.balanceDescriptionMaxLength,
    ),
  );
}
