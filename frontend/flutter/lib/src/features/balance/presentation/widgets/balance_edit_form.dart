import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_double_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_error_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/loading_widget.dart';
import 'package:balance_home_app/src/core/presentation/widgets/custom_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/core/utils/type_util.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_date.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_description.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:balance_home_app/src/features/coin/presentation/widgets/dropdown_picker_field.dart';
import 'package:balance_home_app/src/features/coin/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class BalanceEditForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dateController = TextEditingController();
  final bool edit;
  final BalanceEntity balance;
  final BalanceTypeMode balanceTypeMode;
  BalanceName? _name;
  BalanceDescription? _description;
  BalanceQuantity? _quantity;
  BalanceDate? _date;
  String? _coinType;
  BalanceTypeEntity? _balanceTypeEntity;
  Widget cache = Container();

  BalanceEditForm({
    required this.edit,
    required this.balance,
    required this.balanceTypeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
    _nameController.text = balance.name;
    _descriptionController.text = balance.description;
    _quantityController.text = balance.quantity.toString().replaceAll(".", ",");
    _name = BalanceName(appLocalizations, _nameController.text);
    _description =
        BalanceDescription(appLocalizations, _descriptionController.text);
    _quantity = BalanceQuantity(appLocalizations,
        double.tryParse(_quantityController.text.replaceAll(",", ".")));
    _date = BalanceDate(
        appLocalizations,
        _dateController.text.isNotEmpty
            ? DateTime(
                int.parse(_dateController.text.split("/")[2]),
                int.parse(_dateController.text.split("/")[1]),
                int.parse(_dateController.text.split("/")[0]))
            : DateTime.now());
    if (_dateController.text.isEmpty) {
      _dateController.text =
          "${balance.date.day}/${balance.date.month}/${balance.date.year}";
    }
    final balanceEditControllerProvider =
        balanceTypeMode == BalanceTypeMode.expense
            ? expenseEditControllerProvider
            : revenueEditControllerProvider;
    final balanceListController = balanceTypeMode == BalanceTypeMode.expense
        ? ref.read(expenseListControllerProvider.notifier)
        : ref.read(revenueListControllerProvider.notifier);
    final balanceTypeListControllerProvider =
        balanceTypeMode == BalanceTypeMode.expense
            ? expenseTypeListControllerProvider
            : revenueTypeListControllerProvider;

    final balanceEditController =
        ref.read(balanceEditControllerProvider.notifier);

    final coinTypes = ref.watch(coinTypeListsControllerProvider);
    final balanceTypes = ref.watch(balanceTypeListControllerProvider);
    final balanceEdit = ref.watch(balanceEditControllerProvider);
    _coinType ??= balance.coinType;
    // This is used to refresh page in case handle controller
    return balanceEdit.when(data: (_) {
      return balanceTypes.when(data: (balanceTypes) {
        _balanceTypeEntity ??= balance.balanceType;
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
                          _name = BalanceName(appLocalizations, value),
                      title: appLocalizations.balanceName,
                      validator: (value) => _name?.validate,
                      maxCharacters: 40,
                      maxWidth: 500,
                      controller: _nameController,
                    ),
                    verticalSpace(),
                    CustomTextFormField(
                      readOnly: !edit,
                      onChanged: (value) => _description =
                          BalanceDescription(appLocalizations, value),
                      title: appLocalizations.balanceDescription,
                      validator: (value) => _description?.validate,
                      maxCharacters: 2000,
                      maxWidth: 500,
                      maxHeight: 400,
                      maxLines: 7,
                      multiLine: true,
                      showCounterText: true,
                      controller: _descriptionController,
                    ),
                    verticalSpace(),
                    CustomDoubleFormField(
                      readOnly: !edit,
                      onChanged: (value) =>
                          _quantity = BalanceQuantity(appLocalizations, value),
                      title: appLocalizations.balanceQuantity,
                      validator: (value) => _quantity?.validate,
                      maxWidth: 300,
                      controller: _quantityController,
                    ),
                    verticalSpace(),
                    CustomTextFormField(
                        readOnly: !edit,
                        onTap: () async {
                          // Below line stops keyboard from appearing
                          FocusScope.of(context).requestFocus(FocusNode());
                          // Show Date Picker Here
                          DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now());
                          if (newDate != null) {
                            _date = BalanceDate(appLocalizations, newDate);
                            _dateController.text =
                                "${newDate.day}/${newDate.month}/${newDate.year}";
                          }
                        },
                        controller: _dateController,
                        title: appLocalizations.balanceDate,
                        validator: (value) => _date?.validate,
                        maxWidth: 200),
                    verticalSpace(),
                    (balanceTypes.isNotEmpty)
                        ? DropdownPickerField(
                            readOnly: !edit,
                            name: appLocalizations.balanceType,
                            initialValue: TypeUtil.balanceTypeToString(
                                _balanceTypeEntity!.name, appLocalizations),
                            items: balanceTypes
                                .map((e) => TypeUtil.balanceTypeToString(
                                    e.name, appLocalizations))
                                .toList(),
                            onChanged: (value) {
                              _balanceTypeEntity = balanceTypes.firstWhere(
                                  (element) =>
                                      element.name ==
                                      TypeUtil.stringToBalanceType(
                                          value!, appLocalizations));
                            })
                        : Text(appLocalizations.genericError),
                    (coinTypes.isNotEmpty)
                        ? DropdownPickerField(
                            readOnly: !edit,
                            name: appLocalizations.coinType,
                            initialValue: _coinType!,
                            items: coinTypes.map((e) => e.code).toList(),
                            onChanged: (value) {
                              _coinType = value;
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
                          if (_name == null) return;
                          if (_description == null) return;
                          if (_quantity == null) return;
                          if (_date == null) return;
                          (await balanceEditController.handle(
                                  balance.id!,
                                  _name!,
                                  _description!,
                                  _quantity!,
                                  _date!,
                                  _coinType!,
                                  _balanceTypeEntity!,
                                  appLocalizations))
                              .fold((l) {
                            showErrorBalanceCreationDialog(
                                appLocalizations, l.error, balanceTypeMode);
                          }, (entity) {
                            navigatorKey.currentContext!.go(
                                balanceTypeMode == BalanceTypeMode.expense
                                    ? "/${BalanceView.routeExpensePath}"
                                    : "/${BalanceView.routeRevenuePath}");
                            balanceListController.updateBalance(entity);
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
    }, error: (error, stackTrace) {
      return showError(error, stackTrace, cache: cache);
    }, loading: () {
      return showLoading(cache: cache);
    });
  }
}
