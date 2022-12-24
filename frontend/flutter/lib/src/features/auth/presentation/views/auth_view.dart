import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/presentation/views/error_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/language_picker_dropdown.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/coin/domain/entities/coin_type_entity.dart';
import 'package:balance_home_app/src/features/coin/providers.dart';
import 'package:balance_home_app/src/features/login/presentation/views/login_view.dart';
import 'package:balance_home_app/src/features/register/presentation/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_picker/languages.dart';

class AuthView extends ConsumerWidget {
  /// Named route for [AuthView]
  static const String routeName = 'authentication';

  /// Path route for [AuthView]
  static const String routePath = 'auth';

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final registerUsernameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerPassword2Controller = TextEditingController();
  final registerInvitationCodeController = TextEditingController();
  
  AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final localizationStateNotifier =
        ref.read(appLocalizationsProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      (ref.watch(themeModeProvider) == ThemeMode.dark)
                          ? "assets/images/auth_background_dark_image.jpg"
                          : "assets/images/auth_background_image.jpg"),
                  fit: BoxFit.cover),
            ),
            padding: const EdgeInsets.all(10),
            child: FutureBuilder(
                future: ref.read(coinTypeRepositoryProvider).getCoinTypes(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<CoinTypeEntity>> snapshot) {
                  if (snapshot.hasData) {
                    List<CoinTypeEntity> coinTypes = [];
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      coinTypes = snapshot.data!;
                    } else {
                      ErrorView.go();
                    }
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: CustomLanguagePickerDropdown(
                              appLocalizations: appLocalizations,
                              onValuePicked: (Language language) {
                                Locale locale = Locale(language.isoCode);
                                localizationStateNotifier.setLocale(locale);
                              }),
                        ),
                        if (MediaQuery.of(context).size.height > 600)
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.fromLTRB(
                                  40,
                                  MediaQuery.of(context).size.height * 0.05,
                                  40,
                                  MediaQuery.of(context).size.height * 0.04),
                              child: const AppTittle()),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            initialIndex: 0,
                            child: Column(
                              children: [
                                TabBar(
                                    isScrollable: true,
                                    indicatorColor:
                                        const Color.fromARGB(255, 7, 136, 76),
                                    tabs: [
                                      Tab(
                                        child: Text(
                                          appLocalizations.signIn,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 27, 27, 27),
                                              fontSize: 20),
                                        ),
                                      ),
                                      Tab(
                                        child: Text(
                                          appLocalizations.register,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 27, 27, 27),
                                              fontSize: 20),
                                        ),
                                      )
                                    ]),
                                Expanded(
                                    child: TabBarView(children: [
                                  LoginView(
                                    emailController: loginEmailController,
                                    passwordController: loginPasswordController,
                                  ),
                                  RegisterView(
                                      usernameController:
                                          registerUsernameController,
                                      emailController: registerEmailController,
                                      passwordController:
                                          registerPasswordController,
                                      password2Controller:
                                          registerPassword2Controller,
                                      invitationCodeController:
                                          registerInvitationCodeController,
                                      coinTypes: coinTypes)
                                ])),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    return const Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                })),
      ),
    );
  }
}
