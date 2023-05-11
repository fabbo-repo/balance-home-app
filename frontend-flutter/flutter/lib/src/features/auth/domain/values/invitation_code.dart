import 'package:balance_home_app/src/core/domain/failures/unprocessable_entity_failure.dart';
import 'package:balance_home_app/src/core/domain/values/value_abstract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Invitation Code value
class InvitationCode extends ValueAbstract<String> {
  @override
  Either<UnprocessableEntityFailure, String> get value => _value;
  final Either<UnprocessableEntityFailure, String> _value;

  factory InvitationCode(AppLocalizations appLocalizations, String input) {
    return InvitationCode._(
      _validate(appLocalizations, input),
    );
  }

  const InvitationCode._(this._value);
}

/// * minLength: 1
/// * regex: [a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}
Either<UnprocessableEntityFailure, String> _validate(
    AppLocalizations appLocalizations, String input) {
  if (input.isNotEmpty &&
      RegExp(r"^[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}")
          .hasMatch(input)) {
    return right(input);
  }
  String message = input.isEmpty
      ? appLocalizations.needInvitationCode
      : appLocalizations.invitationCodeNotValid;
  return left(
    UnprocessableEntityFailure(
      detail: message,
    ),
  );
}
