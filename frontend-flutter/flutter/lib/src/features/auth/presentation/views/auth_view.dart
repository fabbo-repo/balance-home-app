import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/presentation/views/background_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/language_picker_dropdown.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/login_form.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/register_form.dart';
import 'package:balance_home_app/src/features/currency/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_picker/languages.dart';
import 'package:universal_io/io.dart';

final lastExitPressState = ValueNotifier<DateTime?>(null);

class AuthView extends ConsumerStatefulWidget {
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
  ConsumerState<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends ConsumerState<AuthView> {
  @visibleForTesting
  Widget cache = Container();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final appLocalizationStateNotifier =
        ref.read(appLocalizationsProvider.notifier);
    final currencyTypeListController =
        ref.watch(currencyTypeListsControllerProvider);
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (lastExitPressState.value != null &&
            now.difference(lastExitPressState.value!) <
                const Duration(seconds: 2)) {
          exit(0);
        } else {
          lastExitPressState.value = now;
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: const AppTittle(fontSize: 30),
            backgroundColor: AppColors.appBarBackgroundColor,
            automaticallyImplyLeading: false),
        body: SafeArea(
          child: BackgroundWidget(
              child: currencyTypeListController.when<Widget>(
                  data: (currencyTypes) {
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
                            emailController: widget.loginEmailController,
                            passwordController: widget.loginPasswordController,
                          ),
                          RegisterForm(
                              usernameController:
                                  widget.registerUsernameController,
                              emailController: widget.registerEmailController,
                              passwordController:
                                  widget.registerPasswordController,
                              password2Controller:
                                  widget.registerPassword2Controller,
                              invitationCodeController:
                                  widget.registerInvitationCodeController,
                              currencyTypes: currencyTypes)
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
                  const AppErrorWidget(),
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
      ),
    );
  }
}
