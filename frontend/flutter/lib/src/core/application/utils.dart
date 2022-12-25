import 'package:balance_home_app/src/core/domain/failures/failure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

class ControllerUtils {
  static T getRight<T>(Either<Failure, T> value, T defaultValue) {
    return value.getRight().getOrElse(() => defaultValue);
  }

  static Failure getLeft<T>(Either<Failure, T> value) {
    return value.getLeft().getOrElse(() => const Failure.empty());
  }

  static AsyncValue<E> asyncError<T, E>(Either<Failure, T> value) {
    return AsyncValue.error(getLeft(value), StackTrace.fromString(""));
  }
}