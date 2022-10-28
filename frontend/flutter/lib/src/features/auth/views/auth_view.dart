import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/views/language_picker_dropdown.dart';
import 'package:balance_home_app/src/features/login/presentation/views/login_view.dart';
import 'package:balance_home_app/src/features/register/presentation/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_picker/languages.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthView extends ConsumerWidget {
  const AuthView({super.key});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    final localizationStateNotifier = ref.read(localizationStateNotifierProvider.notifier);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/auth_background_image.jpg"),
            fit: BoxFit.cover
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: CustomLanguagePickerDropdown(
                appLocalizations: appLocalizations,
                onValuePicked: (Language language) {
                  Locale locale = Locale(language.isoCode);
                  localizationStateNotifier.setLocalization(locale);
                }
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(40, 70, 40, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appLocalizations.appTitle1,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                  Text(
                    appLocalizations.appTitle2,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              )
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                initialIndex: 0,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(
                          child: Text(
                            appLocalizations.signIn,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 27, 27, 27),
                              fontSize: 20
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            appLocalizations.register,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 27, 27, 27),
                              fontSize: 20
                            ),
                          ),
                        )
                      ]
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          LoginView(),
                          RegisterView()
                        ]
                      )
                    ),
                  ],
                ),
              ),
            )  
          ],
        )
      ),
    );
  }
}