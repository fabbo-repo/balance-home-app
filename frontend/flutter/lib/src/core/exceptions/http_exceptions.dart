class UnauthorizedHttpException implements Exception {
  Map<String, dynamic> content;

  UnauthorizedHttpException(this.content);
}


class BadRequestHttpException implements Exception {
  Map<String, dynamic> content;
  
  BadRequestHttpException(this.content);
}