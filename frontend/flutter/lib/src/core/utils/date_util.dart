import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateUtil {
  static List<String> getDaysList(int month, int year) {
    List<String> days = [];
    for (int i = 1; i <= DateUtils.getDaysInMonth(year, month); i++) {
      days.add(i.toString());

      if (DateTime.now().month == month &&
          DateTime.now().year == year &&
          i == DateTime.now().day) break;
    }
    return days;
  }

  static String monthNumToString(int month, AppLocalizations appLocalizations) {
    switch (month) {
      case 1:
        return appLocalizations.january;
      case 2:
        return appLocalizations.february;
      case 3:
        return appLocalizations.march;
      case 4:
        return appLocalizations.april;
      case 5:
        return appLocalizations.may;
      case 6:
        return appLocalizations.june;
      case 7:
        return appLocalizations.july;
      case 8:
        return appLocalizations.august;
      case 9:
        return appLocalizations.september;
      case 10:
        return appLocalizations.october;
      case 11:
        return appLocalizations.november;
      case 12:
        return appLocalizations.december;
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

  static List<String> getMonthList(
      AppLocalizations appLocalizations, {int? year}) {
    List<String> months = [];
    for (int i = 1; i <= 12; i++) {
      switch (i) {
        case 1:
          months.add(appLocalizations.january);
          break;
        case 2:
          months.add(appLocalizations.february);
          break;
        case 3:
          months.add(appLocalizations.march);
          break;
        case 4:
          months.add(appLocalizations.april);
          break;
        case 5:
          months.add(appLocalizations.may);
          break;
        case 6:
          months.add(appLocalizations.june);
          break;
        case 7:
          months.add(appLocalizations.july);
          break;
        case 8:
          months.add(appLocalizations.august);
          break;
        case 9:
          months.add(appLocalizations.september);
          break;
        case 10:
          months.add(appLocalizations.october);
          break;
        case 11:
          months.add(appLocalizations.november);
          break;
        case 12:
          months.add(appLocalizations.december);
          break;
        default:
      }
      if (year == DateTime.now().year && i == DateTime.now().month) {
        return months;
      }
    }
    return months;
  }
}
