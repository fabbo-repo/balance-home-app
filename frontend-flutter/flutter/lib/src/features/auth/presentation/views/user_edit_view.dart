import 'package:balance_home_app/config/api_client.dart';
import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/views/app_titlle.dart';
import 'package:balance_home_app/src/core/presentation/views/background_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/user_delete_view.dart';
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

  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  UserEditView({super.key});

  @override
  ConsumerState<UserEditView> createState() => _UserEditViewState();
}

class _UserEditViewState extends ConsumerState<UserEditView> {
  bool editable = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final isConnected = connectionStateListenable.value;
    return user.when(data: (data) {
      String lastLogin = data == null
          ? "-"
          : data.lastLogin == null
              ? "-"
              : "${data.lastLogin!.toLocal().day}/${data.lastLogin!.toLocal().month}/${data.lastLogin!.toLocal().year} - ${data.lastLogin!.toLocal().hour}:${data.lastLogin!.toLocal().minute}:${data.lastLogin!.toLocal().second}";
      widget.cache.value = Scaffold(
          appBar: AppBar(
            title: const AppTittle(fontSize: 30),
            backgroundColor: AppColors.appBarBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => navigatorKey.currentContext!
                  .goNamed(StatisticsView.routeName),
            ),
            actions: [
              if (isConnected)
                IconButton(
                  icon: Icon(
                    (!editable) ? Icons.edit : Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      editable = !editable;
                    });
                  },
                )
            ],
          ),
          body: SafeArea(
              child: BackgroundWidget(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  (data == null)
                      ? const LoadingWidget()
                      : UserEditForm(edit: editable, user: data),
                  if (!editable && isConnected)
                    AppTextButton(
                      text: appLocalizations.userDelete,
                      height: 40,
                      onPressed: () async {
                        navigatorKey.currentContext!
                            .pushNamed(UserDeleteView.routeName);
                      },
                      backgroundColor: const Color.fromARGB(220, 221, 65, 54),
                    ),
                  verticalSpace(),
                  if (!editable)
                    Text("${appLocalizations.lastLogin}: $lastLogin"),
                  verticalSpace(),
                ],
              ),
            ),
          )));
      return widget.cache.value;
    }, error: (error, _) {
      return showError(
          error: error,
          background: widget.cache.value,
          text: appLocalizations.genericError);
    }, loading: () {
      return showLoading(background: widget.cache.value);
    });
  }
}
