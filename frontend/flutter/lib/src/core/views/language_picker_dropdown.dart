import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';

class CustomLanguagePickerDropdown extends StatelessWidget {
  
  final AppLocalizations appLocalizations;
  final void Function(Language) onValuePicked;

  const CustomLanguagePickerDropdown({
    required this.appLocalizations,
    required this.onValuePicked,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.all(10.0),
      constraints: const BoxConstraints(maxWidth: 180),
      child: LanguagePickerDropdown(
        itemBuilder: (language) {
          return Text(_getLangName(language.isoCode, appLocalizations));
        },
        initialValue: Language(appLocalizations.localeName, 
          _getLangName(appLocalizations.localeName, appLocalizations)),
        languages: AppLocalizations.supportedLocales.map(
          (e) => Language(e.languageCode, 
            _getLangName(e.languageCode, appLocalizations))
        ).toList(),
        onValuePicked: onValuePicked
      ),
    );
  }

  String _getLangName(String code, AppLocalizations appLocalizations) {
    switch (code) {
      case "es":
        return '🇪🇸 ${appLocalizations.spanish}';
      case "en":
        return '🇬🇧 ${appLocalizations.english}';
      case "fr":
        return '🇫🇷 ${appLocalizations.french}';
      default:
        return appLocalizations.unknown;
    }
  }
}