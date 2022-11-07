class ValidationException implements Exception {
  String content;
  
  ValidationException(this.content);

  @override
  String toString() => content;
}