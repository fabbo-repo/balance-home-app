import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/clients/api_client.dart';
import 'package:balance_home_app/src/core/presentation/views/app_title.dart';
import 'package:balance_home_app/src/features/account/presentation/views/account_delete_view.dart';
import 'package:balance_home_app/src/features/auth/presentation/views/auth_background_view.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_loading_widget.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/account/presentation/widgets/account_edit_form.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AccountEditView extends ConsumerStatefulWidget {
  /// Route name
  static const routeName = 'accountEdit';

  /// Route path
  static const routePath = 'account-edit';

  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  AccountEditView({super.key});

  @override
  ConsumerState<AccountEditView> createState() => _AccountEditViewState();
}

class _AccountEditViewState extends ConsumerState<AccountEditView> {
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
              : widget.dateFormatter.format(data.lastLogin!);
      widget.cache.value = Scaffold(
          appBar: AppBar(
            title: const AppTitle(fontSize: 30),
            backgroundColor: AppColors.appBarBackgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => router.goNamed(StatisticsView.routeName),
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
              child: AuthBackgroundWidget(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  (data == null)
                      ? const AppLoadingWidget()
                      : AccountEditForm(edit: editable, user: data),
                  if (!editable && isConnected)
                    AppTextButton(
                      text: appLocalizations.userDelete,
                      height: 40,
                      onPressed: () async {
                        router.pushNamed(AccountDeleteView.routeName);
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
