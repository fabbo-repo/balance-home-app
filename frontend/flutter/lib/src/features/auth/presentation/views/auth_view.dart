import 'package:balance_home_app/src/core/providers/localization_provider.dart';
import 'package:balance_home_app/src/core/services/request_error_handler_libw.dart';
import 'package:balance_home_app/src/core/views/app_titlle.dart';
import 'package:balance_home_app/src/core/widgets/language_picker_dropdown.dart';
import 'package:balance_home_app/src/features/coin/data/models/coin_type_model.dart';
import 'package:balance_home_app/src/features/coin/logic/providers/coin_provider.dart';
import 'package:balance_home_app/src/features/login/presentation/views/login_view.dart';
import 'package:balance_home_app/src/features/register/presentation/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_picker/languages.dart';

class AuthView extends ConsumerWidget {
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final registerUsernameController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerPassword2Controller = TextEditingController();
  final registerInvitationCodeController = TextEditingController();
  final RequestErrorHandlerLibW requestErrorHandler = RequestErrorHandlerLibW();

  AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(localizationStateNotifierProvider).localization;
    final localizationStateNotifier = ref.read(localizationStateNotifierProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/auth_background_image.jpg"),
              fit: BoxFit.cover
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
            future: ref.read(coinTypeRepositoryProvider).getCoinTypes(),
            builder: (BuildContext context, AsyncSnapshot<List<CoinTypeModel>> snapshot) {
              if (snapshot.hasData) {
                List<CoinTypeModel> coinTypes = [];
                if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                  coinTypes = snapshot.data!;
                } else {
                  requestErrorHandler.goToErrorPage();
                }
                return Column(
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
                    if (MediaQuery.of(context).size.height > 400)
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(40, 70, 40, 40),
                        child: const AppTittle()
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
                                  LoginView(
                                    emailController: loginEmailController,
                                    passwordController: loginPasswordController,
                                  ),
                                  RegisterView(
                                    usernameController: registerUsernameController,
                                    emailController: registerEmailController,
                                    passwordController: registerPasswordController,
                                    password2Controller: registerPassword2Controller,
                                    invitationCodeController: registerInvitationCodeController,
                                    coinTypes: coinTypes
                                  )
                                ]
                              )
                            ),
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
            }
          )
        ),
      ),
    );
  }
}