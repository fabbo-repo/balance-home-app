import 'package:balance_home_app/src/core/domain/failures/failure.dart';

/// Expected value is null or empty
class EmptyFailure extends Failure {
  const EmptyFailure() : super(detail: "");
}
