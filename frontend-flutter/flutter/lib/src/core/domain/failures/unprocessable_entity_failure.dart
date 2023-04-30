import 'package:balance_home_app/src/core/domain/failures/failure.dart';

///  Expected value has invalid format
class UnprocessableEntityFailure extends Failure {
  final String message;

  const UnprocessableEntityFailure({required this.message}) : super();
}
