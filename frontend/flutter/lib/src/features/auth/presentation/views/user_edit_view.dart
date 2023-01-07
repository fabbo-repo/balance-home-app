import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/presentation/widgets/user_edit_form.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserEditView extends ConsumerStatefulWidget {
  /// Route name
  static const routeName = 'userEdit';

  /// Route path
  static const routePath = 'user-edit';

  const UserEditView({super.key});

  @override
  ConsumerState<UserEditView> createState() => _UserEditViewState();
}

class _UserEditViewState extends ConsumerState<UserEditView> {
  bool edit = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    return user.when(data: (data) {
      return Scaffold(
          appBar: AppBar(
            title: const AppTittle(fontSize: 30),
            backgroundColor: AppColors.appBarBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => navigatorKey.currentContext!
                  .goNamed(StatisticsView.routeName),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  (!edit) ? Icons.edit : Icons.cancel_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    edit = !edit;
                  });
                },
              )
            ],
          ),
          body: SafeArea(
              child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      ref.watch(themeModeProvider) == ThemeMode.dark
                          ? "assets/images/auth_background_dark_image.jpg"
                          : "assets/images/auth_background_image.jpg"),
                  fit: BoxFit.cover),
            ),
            constraints: const BoxConstraints.expand(),
            child: UserEditForm(edit: edit, user: data!),
          )));
    }, error: (o, st) {
      return showError(o, st);
    }, loading: () {
      return showLoading();
    });
  }
}
