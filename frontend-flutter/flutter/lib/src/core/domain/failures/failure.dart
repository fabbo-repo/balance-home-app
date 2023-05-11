/// Represents all generic app failures
abstract class Failure implements Exception {
  final String detail;

  const Failure({required this.detail}) : super();
}
