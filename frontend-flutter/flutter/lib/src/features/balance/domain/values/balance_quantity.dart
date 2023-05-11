import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Balance Quanity value
class BalanceQuantity extends ValueAbstract<double?> {
  @override
  Either<Failure, double> get value => _value;
  final Either<Failure, double> _value;

  factory BalanceQuantity(AppLocalizations appLocalizations, double? input) {
    return BalanceQuantity._(
      _validate(appLocalizations, input),
    );
  }

  const BalanceQuantity._(this._value);
}

/// * minimum: 0
Either<Failure, double> _validate(
    AppLocalizations appLocalizations, double? input) {
  if (input != null && input >= 0) {
    return right(input);
  }
  String message = input == null
      ? appLocalizations.balanceQuantityRequired
      : appLocalizations.balanceQuantityMinValue;
  return left(
    UnprocessableEntityFailure(
      detail: message,
    ),
  );
}
