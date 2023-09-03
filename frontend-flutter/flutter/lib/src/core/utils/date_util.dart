import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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
    return DateFormat("MMM", appLocalizations.localeName)
        .format(DateTime(DateTime.now().year, month));
  }

  static Map<int, String> getMonthDict(AppLocalizations appLocalizations,
      {int? year}) {
    final monthDict = <int, String>{};
    final monthFormatter = DateFormat.MMM(appLocalizations.localeName);
    final now = DateTime.now();
    for (int monthIndex = 1; monthIndex <= 12; monthIndex++) {
      monthDict[monthIndex] =
          monthFormatter.format(DateTime(now.year, monthIndex));
      if (year == now.year && monthIndex == now.month) {
        return monthDict;
      }
    }
    return monthDict;
  }
}
