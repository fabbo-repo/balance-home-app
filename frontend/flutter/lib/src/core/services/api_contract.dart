/// Defines the relative URLs for the server endpoints.
class APIContract {
  /*
   * ============ JWT login ============ *
   */
  /// [POST] Returns JWT access and refresh token
  static const String jwtLogin = "jwt";

  /*
   * ============ JWT refresh ============ *
   */
  /// [POST] Returns new JWT access token
  static const String jwtRefresh = "jwt/refresh";

  /*
   * ============ COIN ============ *
   */
  /// [GET] Returns Coin type
  static const String coinType = "coin";
}