import 'package:balance_home_app/src/core/domain/failures/failure.dart';

/// Represents an unexistant entity stored failure
class NoLocalEntityFailure extends Failure {
  final String entityName;

  const NoLocalEntityFailure({required this.entityName, required super.detail});
}
