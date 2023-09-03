import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/core/presentation/views/app_title.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_background_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_language_picker_dropdown.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/login_form.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/register_form.dart';
import 'package:balance_home_app/src/features/currency/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_picker/languages.dart';
import 'package:universal_io/io.dart';

final lastExitPressState = ValueNotifier<DateTime?>(null);

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

  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  AuthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            title: const AppTitle(fontSize: 30),
            backgroundColor: AppColors.appBarBackgroundColor,
            automaticallyImplyLeading: false),
        body: SafeArea(
          child: AuthBackgroundWidget(
              child: currencyTypeListController.when<Widget>(data: (data) {
            return data.fold((failure) {
              if (failure is HttpConnectionFailure ||
                  failure is NoLocalEntityFailure) {
                return showError(
                    icon: Icons.network_wifi_1_bar,
                    text: appLocalizations.noConnection);
              }
              return showError(background: cache.value, text: failure.detail);
            }, (currencyTypes) {
              cache.value = Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: AppLanguagePickerDropdown(
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
                                    style: GoogleFonts.openSans(
                                        color: const Color.fromARGB(
                                            255, 27, 27, 27),
                                        fontSize: 20),
                                  ),
                                ),
                                Tab(
                                  child: Text(
                                    appLocalizations.register,
                                    style: GoogleFonts.openSans(
                                        color: const Color.fromARGB(
                                            255, 27, 27, 27),
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
                                currencyTypes: currencyTypes)
                          ])),
                        ],
                      ),
                    ),
                  )
                ],
              );
              return cache.value;
            });
          }, error: (error, _) {
            return showError(
                error: error,
                background: cache.value,
                text: appLocalizations.genericError);
          }, loading: () {
            return showLoading(background: cache.value);
          })),
        ),
      ),
    );
  }
}
