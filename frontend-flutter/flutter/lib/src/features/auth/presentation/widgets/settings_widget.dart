import 'package:balance_home_app/src/core/presentation/widgets/language_picker_dropdown.dart';
import 'package:balance_home_app/src/core/presentation/widgets/text_check_box.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_picker/languages.dart';

class SettingsWidget extends ConsumerStatefulWidget {
  final UserEntity user;

  const SettingsWidget({
    required this.user,
    super.key,
  });

  @override
  ConsumerState<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends ConsumerState<SettingsWidget> {
  Widget cache = Container();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);

    final theme = ref.watch(themeModeProvider);
    final themeStateNotifier = ref.read(themeModeProvider.notifier);
    final appLocalizationStateNotifier =
        ref.read(appLocalizationsProvider.notifier);
    // This is used to refresh page in case handle controller
    return settings.when(data: (_) {
      cache = Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            verticalSpace(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  appLocalizations.language,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 70, 70, 70), fontSize: 18),
                ),
                horizontalSpace(),
                CustomLanguagePickerDropdown(
                    appLocalizations: appLocalizations,
                    onValuePicked: (Language language) async {
                      Locale locale = Locale(language.isoCode);
                      appLocalizationStateNotifier.setLocale(locale);
                      (await settingsController.handleLanguage(
                              widget.user, locale, appLocalizations))
                          .fold((failure) {
                        showErrorSettingsDialog(
                            appLocalizations, failure.error);
                      }, (_) {
                        authController.refreshUserData();
                      });
                    }),
              ],
            ),
            verticalSpace(),
            verticalSpace(),
            TextCheckBox(
                title: appLocalizations.darkMode,
                isChecked: theme == ThemeMode.dark,
                fillColor: const Color.fromARGB(255, 70, 70, 70),
                onChanged: (value) async {
                  themeStateNotifier.setThemeMode(value != null && value
                      ? ThemeMode.dark
                      : ThemeMode.light);
                  await settingsController.handleThemeMode(
                      value! ? ThemeMode.dark : ThemeMode.light,
                      appLocalizations);
                }),
            verticalSpace(),
            verticalSpace(),
            TextCheckBox(
                title: appLocalizations.receiveEmailBalance,
                isChecked: widget.user.receiveEmailBalance,
                fillColor: const Color.fromARGB(255, 70, 70, 70),
                onChanged: (value) async {
                  await settingsController.handleReceiveEmailBalance(
                      widget.user, value!, appLocalizations);
                  authController.refreshUserData();
                }),
            verticalSpace(),
          ],
        ),
      );
      return cache;
    }, error: (error, stackTrace) {
      return showError(error, stackTrace, cache: cache);
    }, loading: () {
      return showLoading(cache: cache);
    });
  }
}
