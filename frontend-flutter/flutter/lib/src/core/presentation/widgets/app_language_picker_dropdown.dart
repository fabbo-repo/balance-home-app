import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';

class AppLanguagePickerDropdown extends StatelessWidget {
  final AppLocalizations appLocalizations;
  final void Function(Language) onValuePicked;

  const AppLanguagePickerDropdown(
      {required this.appLocalizations, required this.onValuePicked, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.light ?
        Colors.grey[300] : Colors.grey[600],
      padding: const EdgeInsets.all(10.0),
      constraints: const BoxConstraints(maxWidth: 180),
      child: LanguagePickerDropdown(
          itemBuilder: (language) {
            return Row(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: _getFlag(language.isoCode)),
              Text(_getLangName(language.isoCode, appLocalizations))
            ]);
          },
          initialValue: Language(appLocalizations.localeName,
              _getLangName(appLocalizations.localeName, appLocalizations)),
          languages: AppLocalizations.supportedLocales
              .map((e) => Language(e.languageCode,
                  _getLangName(e.languageCode, appLocalizations)))
              .toList(),
          onValuePicked: onValuePicked),
    );
  }

  String _getLangName(String code, AppLocalizations appLocalizations) {
    switch (code) {
      case "es":
        return appLocalizations.spanish;
      case "en":
        return appLocalizations.english;
      case "fr":
        return appLocalizations.french;
      default:
        return appLocalizations.unknown;
    }
  }

  Widget _getFlag(String code) {
    switch (code) {
      case "es":
        return const Flag.fromString("es", height: 15, width: 15);
      case "en":
        return const Flag.fromString("gb", height: 15, width: 15);
      case "fr":
        return const Flag.fromString("fr", height: 15, width: 15);
      default:
        return Container();
    }
  }
}
