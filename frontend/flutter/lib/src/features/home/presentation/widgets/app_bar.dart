import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/platform_utils.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/presentation/views/logout_view.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).asData?.value;
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return AppBar(
      automaticallyImplyLeading: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white10,
          statusBarBrightness: Brightness.dark, //Dark icons for Android
          statusBarIconBrightness: Brightness.dark //Dark icons for iOS
          ),
      titleSpacing: 0,
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.appBarBackgroundColor,
      // If platform window is considered as large or medium, then the [AppTittle]
      // should be shown, otherwise if mobile is the current platform nothing will be shown,
      // else cases a balance counter should be rendered
      title: (PlatformUtils().isLargeWindow(context) ||
              PlatformUtils().isMediumWindow(context))
          ? const AppTittle(fontSize: 30)
          : _balanceBox(appLocalizations, user),
      leading: (PlatformUtils().isLargeWindow(context) ||
              PlatformUtils().isMediumWindow(context))
          ? _balanceBox(appLocalizations, user)
          : null,
      leadingWidth: (PlatformUtils().isLargeWindow(context) ||
              PlatformUtils().isMediumWindow(context))
          ? 250
          : 0,
      actions: [_profileButton(appLocalizations, user)],
    );
  }

  /// Returns a [Widget] that includes an account balance counter and
  /// the coint type setup in the account.
  Widget _balanceBox(AppLocalizations appLocalizations, UserEntity? user) {
    return Container(
        width: 400,
        height: 100,
        color: const Color.fromARGB(255, 12, 12, 12),
        child: Center(
          child: Text(
            "${appLocalizations.balance}: ${user == null ? 0 : user.balance} "
            "${user == null ? "" : user.prefCoinType}",
            style: const TextStyle(color: Colors.white),
          ),
        ));
  }

  /// Returns a [Widget] that includes a button with the image
  /// profile and name of the user account.
  Widget _profileButton(AppLocalizations appLocalizations, UserEntity? user) {
    return PopupMenuButton(
      color: const Color.fromARGB(255, 80, 80, 80),
      onSelected: (value) {
        if (value == 0) {
          // TODO Go to my account
        } else if (value == 1) {
          // TODO Go to settings
        } else if (value == 2) {
          // It cannot call authController because it would change provider
          // while changing the entire three and that leads to an error
          navigatorKey.currentContext!.goNamed(LogoutView.routeName);
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<int>(
            value: 0,
            child: Text(appLocalizations.myAccount),
          ),
          // TODO: (Dark mode and language)
          //PopupMenuItem<int>(
          //  value: 1,
          //  child: Text(appLocalizations.settings),
          //),
          PopupMenuItem<int>(
            value: 2,
            child: Text(appLocalizations.logout),
          ),
        ];
      },
      child: Row(
        children: [
          if (user != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1),
              ),
              margin: const EdgeInsets.all(4),
              child: Image.network(user.image),
            ),
          if (user != null)
            if (!PlatformUtils().isMobile)
              Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(
                  user.username,
                  style: const TextStyle(
                      fontSize: 17, color: Color.fromARGB(255, 202, 202, 202)),
                ),
              )
        ],
      ),
    );
  }
}
