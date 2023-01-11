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
  
  static String stringToBalanceType(String type, AppLocalizations appLocalizations) {
    if (appLocalizations.bizum == type) return "bizum";
    if (appLocalizations.deposit == type) return "deposit";
    if (appLocalizations.gift == type) return "gift";
    if (appLocalizations.refund == type) return "refund";
    if (appLocalizations.salary == type) return "salary";
    if (appLocalizations.sales == type) return "sales";
    if (appLocalizations.savings == type) return "savings";
    if (appLocalizations.transfer == type) return "transfer";
    if (appLocalizations.bills == type) return "bills";
    if (appLocalizations.car == type) return "car";
    if (appLocalizations.clothes == type) return "clothes";
    if (appLocalizations.entertainment == type) return "entertainment";
    if (appLocalizations.food == type) return "food";
    if (appLocalizations.hairdresser == type) return "hairdresser";
    if (appLocalizations.health == type) return "health";
    if (appLocalizations.home == type) return "home";
    if (appLocalizations.others == type) return "others";
    if (appLocalizations.petrol == type) return "petrol";
    if (appLocalizations.shopping == type) return "shopping";
    if (appLocalizations.sports == type) return "sports";
    if (appLocalizations.studies == type) return "studies";
    if (appLocalizations.vacation == type) return "vacation";
    return type;
  }
}