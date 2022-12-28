import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TypeUtil {
  static String balanceTypeToString(String type, AppLocalizations appLocalizations) {
    switch (type) {
      case "bizum": return appLocalizations.bizum;
      case "deposit": return appLocalizations.deposit;
      case "gift": return appLocalizations.gift;
      case "refund": return appLocalizations.refund;
      case "salary": return appLocalizations.salary;
      case "sales": return appLocalizations.sales;
      case "savings": return appLocalizations.savings;
      case "transfer": return appLocalizations.transfer;
      case "bills": return appLocalizations.bills;
      case "car": return appLocalizations.car;
      case "clothes": return appLocalizations.clothes;
      case "entertainment": return appLocalizations.entertainment;
      case "food": return appLocalizations.food;
      case "hairdresser": return appLocalizations.hairdresser;
      case "health": return appLocalizations.health;
      case "home": return appLocalizations.home;
      case "others": return appLocalizations.others;
      case "petrol": return appLocalizations.petrol;
      case "shopping": return appLocalizations.shopping;
      case "sports": return appLocalizations.sports;
      case "studies": return appLocalizations.studies;
      case "vacation": return appLocalizations.vacation;
    }
    return type;
  }
}