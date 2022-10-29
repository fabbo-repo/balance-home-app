/// Defines the relative URLs for the backend server endpoints.
class APIContract {
  /*
   * ============ Frontend version ============ *
   */
  /// [GET] Returns last version of frontend app
  static const String frontendVersion = "api/v1/frontend/version";

  /*
   * ============ JWT login ============ *
   */
  /// [POST] Returns JWT access and refresh token
  static const String jwtLogin = "api/v1/jwt";

  /*
   * ============ JWT refresh ============ *
   */
  /// [POST] Returns new JWT access token
  static const String jwtRefresh = "api/v1/jwt/refresh";

  /*
   * ============ User ============ *
   */
  /// [GET], [PUT], [PATCH], [DEL] User profile info
  static const String userProfile = "api/v1/user/profile";
  /// [POST] User creation
  static const String userCreation = "api/v1/user";
  /// [GET], [POST] User password reset
  static const String userPasswordReset = "api/v1/user/password/reset";
  /// [POST] User password change
  static const String userPasswordChange = "api/v1/user/password/change";

  /*
   * ============ Email code ============ *
   */
  /// [POST] Send email code
  static const String emailCodeSend = "api/v1/email_code/send";
  /// [POST] Verify sent email code
  static const String emailCodeVerify = "api/v1/email_code/verify";
  
  /*
   * ============ Annual balance ============ *
   */
  /// [GET] Returns annual balance
  static const String annualBalanceList = "api/v1/annual_balance";
  
  /*
   * ============ Monthly balance ============ *
   */
  /// [GET] Returns monthly balance
  static const String monthlyBalanceList = "api/v1/monthly_balance";
  
  /*
   * ============ Coin ============ *
   */
  /// [GET] Returns coin exchange
  static const String coinExchange = "api/v1/coin/exchange";
  /// [GET] Returns coin type
  static const String coinType = "api/v1/coin/type";
  
  /*
   * ============ Revenue ============ *
   */
  /// [GET], [PUT], [PATCH], [DEL] Revenue info
  static const String revenue = "api/v1/revenue";
  /// [GET] Returns revenue type
  static const String revenueType = "api/v1/revenue/type";
  
  /*
   * ============ Expense ============ *
   */
  /// [GET], [PUT], [PATCH], [DEL] Expense info
  static const String expense = "api/v1/expense";
  /// [GET] Returns expense type
  static const String expenseType = "api/v1/expense/type";
}