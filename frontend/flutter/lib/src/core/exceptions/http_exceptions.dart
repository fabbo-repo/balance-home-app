class UnauthorizedHttpException implements Exception {
  Map<String, dynamic> content;

  UnauthorizedHttpException(this.content);
  
  @override
  String toString() => "UnauthorizedRequest: $content";
}


class BadRequestHttpException implements Exception {
  Map<String, dynamic> content;
  
  BadRequestHttpException(this.content);

  @override
  String toString() => "BadRequest: $content";
}