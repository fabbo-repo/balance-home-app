import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateUtil {
  static String monthNumToString(int month, AppLocalizations appLocalizations) {
    switch (month) {
      case 1: return appLocalizations.january;
      case 2: return appLocalizations.february;
      case 3: return appLocalizations.march;
      case 4: return appLocalizations.april;
      case 5: return appLocalizations.may;
      case 6: return appLocalizations.june;
      case 7: return appLocalizations.july;
      case 8: return appLocalizations.august;
      case 9: return appLocalizations.september;
      case 10: return appLocalizations.october;
      case 11: return appLocalizations.november;
      case 12: return appLocalizations.december;
    }
    return appLocalizations.january;
  }

  static int monthStringToNum(String month, AppLocalizations appLocalizations) {
    if (month == appLocalizations.january) return 1;
    if (month == appLocalizations.february) return 2;
    if (month == appLocalizations.march) return 3;
    if (month == appLocalizations.april) return 4;
    if (month == appLocalizations.may) return 5;
    if (month == appLocalizations.june) return 6;
    if (month == appLocalizations.july) return 7;
    if (month == appLocalizations.august) return 8;
    if (month == appLocalizations.september) return 9;
    if (month == appLocalizations.october) return 10;
    if (month == appLocalizations.november) return 11;
    if (month == appLocalizations.december) return 12;
    return -1;
  }

  static List<String> getMonthList(AppLocalizations appLocalizations) {
    return [
      appLocalizations.january,
      appLocalizations.february,
      appLocalizations.march,
      appLocalizations.april,
      appLocalizations.may,
      appLocalizations.june,
      appLocalizations.july,
      appLocalizations.august,
      appLocalizations.september,
      appLocalizations.october,
      appLocalizations.november,
      appLocalizations.december
    ];
  }
}