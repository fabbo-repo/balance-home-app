import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/language_picker_dropdown.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/login_form.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/register_form.dart';
import 'package:balance_home_app/src/features/coin/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_picker/languages.dart';

// ignore: must_be_immutable
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

  Widget cache = Container();

  AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final appLocalizationStateNotifier =
        ref.read(appLocalizationsProvider.notifier);
    final coinTypeListController = ref.watch(coinTypeListsControllerProvider);
    return Scaffold(
      appBar: AppBar(
          title: const AppTittle(fontSize: 30),
          backgroundColor: AppColors.appBarBackgroundColor,
          automaticallyImplyLeading: false),
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
            child: coinTypeListController.when<Widget>(data: (coinTypes) {
              cache = Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: CustomLanguagePickerDropdown(
                        appLocalizations: appLocalizations,
                        onValuePicked: (Language language) {
                          Locale locale = Locale(language.isoCode);
                          appLocalizationStateNotifier.setLocale(locale);
                        }),
                  ),
                  const SizedBox(height: AppLayout.genericPadding),
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
                                        color: Color.fromARGB(255, 27, 27, 27),
                                        fontSize: 20),
                                  ),
                                ),
                                Tab(
                                  child: Text(
                                    appLocalizations.register,
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 27, 27, 27),
                                        fontSize: 20),
                                  ),
                                )
                              ]),
                          Expanded(
                              child: TabBarView(children: [
                            LoginForm(
                              emailController: loginEmailController,
                              passwordController: loginPasswordController,
                            ),
                            RegisterForm(
                                usernameController: registerUsernameController,
                                emailController: registerEmailController,
                                passwordController: registerPasswordController,
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
              return cache;
            }, error: (error, stackTrace) {
              debugPrint("[RESET_PASSWORD_FORM] $error -> $stackTrace");
              return Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    cache,
                    const CustomErrorWidget(),
                  ]);
            }, loading: () {
              return Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    cache,
                    const LoadingWidget(color: Colors.grey),
                  ]);
            })),
      ),
    );
  }
}
