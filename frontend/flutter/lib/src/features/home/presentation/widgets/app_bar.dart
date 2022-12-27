import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/platform_utils.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).asData!.value;
    final appLocalizations = ref.watch(appLocalizationsProvider);
    return AppBar(
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
          : _balanceBox(appLocalizations, user!),
      leading: (PlatformUtils().isLargeWindow(context) ||
              PlatformUtils().isMediumWindow(context))
          ? _balanceBox(appLocalizations, user!)
          : null,
      leadingWidth: (PlatformUtils().isLargeWindow(context) ||
              PlatformUtils().isMediumWindow(context))
          ? 200
          : 0,
      actions: [_profileButton(user!)],
    );
  }

  /// Returns a [Widget] that includes an account balance counter and
  /// the coint type setup in the account.
  Widget _balanceBox(AppLocalizations appLocalizations, UserEntity user) {
    return Container(
        width: 400,
        height: 100,
        color: const Color.fromARGB(255, 12, 12, 12),
        child: Center(
          child: Text(
            "${appLocalizations.balance}: ${user.balance} ${user.prefCoinType}",
            style: const TextStyle(color: Colors.white),
          ),
        ));
  }

  /// Returns a [Widget] that includes a button with the image
  /// profile and name of the user account.
  Widget _profileButton(UserEntity user) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            const Color.fromARGB(255, 80, 80, 80)),
      ),
      onPressed: () {},
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1),
            ),
            margin: const EdgeInsets.all(4),
            child: Image.network(user.image),
          ),
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
