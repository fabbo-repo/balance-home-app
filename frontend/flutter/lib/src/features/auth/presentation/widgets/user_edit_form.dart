import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_double_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/domain/entities/user_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/user_name.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:balance_home_app/src/features/coin/presentation/widgets/dropdown_picker_field.dart';
import 'package:balance_home_app/src/features/coin/providers.dart';
import 'package:balance_home_app/src/features/statistics/presentation/views/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universal_io/io.dart';

// ignore: must_be_immutable
class UserEditForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _expectedMonthlyBalanceController = TextEditingController();
  final _expectedAnnualBalanceController = TextEditingController();
  final bool edit;
  final UserEntity user;
  UserName? _username;
  UserEmail? _email;
  BalanceQuantity? _expectedMonthlyBalance;
  BalanceQuantity? _expectedAnnualBalance;
  String? _prefCoinType;
  File? _image;
  Widget cache = Container();

  UserEditForm({
    required this.edit,
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _expectedMonthlyBalanceController.text =
        user.expectedMonthlyBalance.toString().replaceAll(".", ",");
    _expectedAnnualBalanceController.text =
        user.expectedAnnualBalance.toString().replaceAll(".", ",");
    _username = UserName(appLocalizations, _usernameController.text);
    _email = UserEmail(appLocalizations, _emailController.text);
    _expectedMonthlyBalance = BalanceQuantity(
        appLocalizations,
        double.tryParse(
            _expectedMonthlyBalanceController.text.replaceAll(",", ".")));
    _expectedAnnualBalance = BalanceQuantity(
        appLocalizations,
        double.tryParse(
            _expectedAnnualBalanceController.text.replaceAll(",", ".")));
    _prefCoinType ??= user.prefCoinType;

    final coinTypes = ref.watch(coinTypeListsControllerProvider);
    final userEdit = ref.watch(userEditControllerProvider);
    final userEditController = ref.read(userEditControllerProvider.notifier);
    // This is used to refresh page in case handle controller
    return userEdit.when(data: (_) {
      return coinTypes.when(data: (coinTypes) {
        cache = SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  verticalSpace(),
                  CustomTextFormField(
                    readOnly: !edit,
                    onChanged: (value) =>
                        _username = UserName(appLocalizations, value),
                    title: appLocalizations.username,
                    validator: (value) => _username?.validate,
                    maxCharacters: 40,
                    maxWidth: 500,
                    controller: _usernameController,
                  ),
                  verticalSpace(),
                  CustomTextFormField(
                    readOnly: true,
                    onChanged: (value) =>
                        _email = UserEmail(appLocalizations, value),
                    title: appLocalizations.emailAddress,
                    validator: (value) => _email?.validate,
                    maxCharacters: 40,
                    maxWidth: 500,
                    controller: _emailController,
                  ),
                  verticalSpace(),
                  CustomDoubleFormField(
                    readOnly: !edit,
                    onChanged: (value) => _expectedMonthlyBalance =
                        BalanceQuantity(appLocalizations, value),
                    title: appLocalizations.expectedMonthlyBalance,
                    validator: (value) => _expectedMonthlyBalance?.validate,
                    maxWidth: 300,
                    controller: _expectedMonthlyBalanceController,
                  ),
                  verticalSpace(),
                  CustomDoubleFormField(
                    readOnly: !edit,
                    onChanged: (value) => _expectedAnnualBalance =
                        BalanceQuantity(appLocalizations, value),
                    title: appLocalizations.expectedAnnualBalance,
                    validator: (value) => _expectedAnnualBalance?.validate,
                    maxWidth: 300,
                    controller: _expectedAnnualBalanceController,
                  ),
                  verticalSpace(),
                  (coinTypes.isNotEmpty)
                      ? DropdownPickerField(
                          readOnly: !edit,
                          name: appLocalizations.coinType,
                          initialValue: _prefCoinType!,
                          items: coinTypes.map((e) => e.code).toList(),
                          onChanged: (value) {
                            _prefCoinType = value;
                          })
                      : Text(appLocalizations.genericError),
                  verticalSpace(),
                  if (edit)
                    CustomTextButton(
                      text: appLocalizations.confirmation,
                      width: 160,
                      height: 50,
                      onPressed: () async {
                        if (_formKey.currentState == null ||
                            !_formKey.currentState!.validate()) {
                          return;
                        }
                        if (_username == null) return;
                        if (_email == null) return;
                        if (_expectedMonthlyBalance == null) return;
                        if (_expectedAnnualBalance == null) return;
                        (await userEditController.handle(
                                user,
                                _username!,
                                _email!,
                                _expectedMonthlyBalance!,
                                _expectedAnnualBalance!,
                                _prefCoinType!,
                                appLocalizations))
                            .fold((l) {
                          showErrorUserEditDialog(
                              appLocalizations, l.error);
                        }, (entity) {
                          navigatorKey.currentContext!.goNamed(StatisticsView.routeName);
                          authController.refreshUserData();
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        );
        return cache;
      }, error: (error, stackTrace) {
        return showError(error, stackTrace, cache: cache);
      }, loading: () {
        return showLoading(cache: cache);
      });
    }, error: (error, stackTrace) {
      return showError(error, stackTrace, cache: cache);
    }, loading: () {
      return showLoading(cache: cache);
    });
  }
}
