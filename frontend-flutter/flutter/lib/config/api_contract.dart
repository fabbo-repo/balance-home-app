/// Defines the relative URLs for the backend server endpoints.
class APIContract {
  /*
   * ============ Frontend version ============ *
   */
  /// [GET] Returns last version of frontend app
  static const String frontendVersion = "/api/v1/frontend/version";

  /*
   * ============ User ============ *
   */
  /// [GET], [PUT], [PATCH], [DEL] User profile info
  static const String userProfile = "/api/v1/user/profile";

  /// [POST] User creation
  static const String userCreation = "/api/v1/user";

  /// [POST] User password reset send code
  static const String userPasswordReset = "/api/v1/user/password/reset";

  /// [POST] User password change
  static const String userPasswordChange = "/api/v1/user/password/change";

  /*
   * ============ Email code ============ *
   */
  /// [POST] Send email code
  static const String emailCodeSend = "/api/v1/email_code/send";

  /// [POST] Verify sent email code
  static const String emailCodeVerify = "/api/v1/email_code/verify";

  /*
   * ============ Annual balance ============ *
   */
  /// [GET] Returns annual balance
  static const String annualBalance = "/api/v1/annual_balance";

  /*
   * ============ Monthly balance ============ *
   */
  /// [GET] Returns monthly balance
  static const String monthlyBalance = "/api/v1/monthly_balance";

  /*
   * ============ Currency ============ *
   */
  /// [GET] Returns currency conversion
  static const String currencyConversion = "/api/v1/coin/exchange";

  /// [GET] Returns currency type
  static const String currencyType = "/api/v1/coin/type";

  /*
   * ============ Revenue ============ *
   */
  /// [GET], [PUT], [PATCH], [DEL] Revenue info
  static const String revenue = "/api/v1/revenue";

  /// [GET] Returns revenue type
  static const String revenueType = "/api/v1/revenue/type";

  /// [GET] Returns revenue years
  static const String revenueYears = "/api/v1/revenue/years";

  /*
   * ============ Expense ============ *
   */
  /// [GET], [PUT], [PATCH], [DEL] Expense info
  static const String expense = "/api/v1/expense";

  /// [GET] Returns expense type
  static const String expenseType = "/api/v1/expense/type";

  /// [GET] Returns expense years
  static const String expenseYears = "/api/v1/expense/years";
}
