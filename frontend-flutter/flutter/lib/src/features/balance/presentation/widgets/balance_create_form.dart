import 'package:balance_home_app/config/router.dart';
import 'package:balance_home_app/src/core/presentation/widgets/double_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_date.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_description.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:balance_home_app/src/features/balance/presentation/views/balance_view.dart';
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_type_dropdown_picker.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:balance_home_app/src/features/coin/presentation/widgets/dropdown_picker_field.dart';
import 'package:balance_home_app/src/features/coin/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class BalanceCreateForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dateController = TextEditingController();
  BalanceName? _name;
  BalanceDescription? _description;
  BalanceQuantity? _quantity;
  BalanceDate? _date;
  String? _coinType;
  BalanceTypeEntity? _balanceTypeEntity;
  final BalanceTypeMode balanceTypeMode;
  Widget cache = Container();

  BalanceCreateForm({
    required this.balanceTypeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
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
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    }
    final balanceCreateControllerProvider =
        balanceTypeMode == BalanceTypeMode.expense
            ? expenseCreateControllerProvider
            : revenueCreateControllerProvider;
    final balanceListController = balanceTypeMode == BalanceTypeMode.expense
        ? ref.read(expenseListControllerProvider.notifier)
        : ref.read(revenueListControllerProvider.notifier);
    final balanceTypeListControllerProvider =
        balanceTypeMode == BalanceTypeMode.expense
            ? expenseTypeListControllerProvider
            : revenueTypeListControllerProvider;

    final balanceCreateController =
        ref.read(balanceCreateControllerProvider.notifier);

    final user = ref.watch(authControllerProvider);
    final balanceCreate = ref.watch(balanceCreateControllerProvider);
    final coinTypes = ref.watch(coinTypeListsControllerProvider);
    final balanceTypes = ref.watch(balanceTypeListControllerProvider);
    return user.when(data: (user) {
      _coinType ??= user!.prefCoinType;
      // This is used to refresh page in case handle controller
      return balanceCreate.when(data: (_) {
        return balanceTypes.when(data: (balanceTypes) {
          _balanceTypeEntity ??= balanceTypes[0];
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
                      AppTextFormField(
                        onChanged: (value) =>
                            _name = BalanceName(appLocalizations, value),
                        title: appLocalizations.balanceName,
                        validator: (value) => _name?.validate,
                        maxCharacters: 40,
                        maxWidth: 500,
                        controller: _nameController,
                      ),
                      verticalSpace(),
                      AppTextFormField(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DoubleFormField(
                            onChanged: (value) => _quantity =
                                BalanceQuantity(appLocalizations, value),
                            title: appLocalizations.balanceQuantity,
                            validator: (value) => _quantity?.validate,
                            maxWidth: 200,
                            controller: _quantityController,
                            align: TextAlign.end,
                          ),
                          (coinTypes.isNotEmpty)
                              ? DropdownPickerField(
                                  initialValue: _coinType!,
                                  items: coinTypes.map((e) => e.code).toList(),
                                  width: 100,
                                  onChanged: (value) {
                                    _coinType = value;
                                  })
                              : const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                        ],
                      ),
                      verticalSpace(),
                      AppTextFormField(
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
                          textAlign: TextAlign.center,
                          controller: _dateController,
                          title: appLocalizations.balanceDate,
                          validator: (value) => _date?.validate,
                          maxWidth: 200),
                      verticalSpace(),
                      (balanceTypes.isNotEmpty)
                          ? BalanceTypeDropdownPicker(
                              name: appLocalizations.balanceType,
                              initialValue: _balanceTypeEntity!,
                              items: balanceTypes,
                              onChanged: (value) {
                                _balanceTypeEntity = value!;
                              },
                              appLocalizations: appLocalizations,
                            )
                          : Text(appLocalizations.genericError),
                      verticalSpace(),
                      AppTextButton(
                        width: 140,
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
                          (await balanceCreateController.handle(
                                  _name!,
                                  _description!,
                                  _quantity!,
                                  _date!,
                                  _coinType!,
                                  _balanceTypeEntity!,
                                  appLocalizations))
                              .fold((failure) {
                            showErrorBalanceCreationDialog(appLocalizations,
                                failure.message, balanceTypeMode);
                          }, (entity) {
                            navigatorKey.currentContext!.go(
                                balanceTypeMode == BalanceTypeMode.expense
                                    ? "/${BalanceView.routeExpensePath}"
                                    : "/${BalanceView.routeRevenuePath}");
                            balanceListController.addBalance(entity);
                            authController.refreshUserData();
                          });
                        },
                        text: appLocalizations.create,
                      ),
                    ],
                  ),
                ),
              ),
            );
            return cache;
          }, error: (o, st) {
            return showError(o, st, cache: cache);
          }, loading: () {
            return showLoading(cache: cache);
          });
        }, error: (o, st) {
          return showError(o, st, cache: cache);
        }, loading: () {
          return showLoading(cache: cache);
        });
      }, error: (o, st) {
        return showError(o, st, cache: cache);
      }, loading: () {
        return showLoading(cache: cache);
      });
    }, error: (o, st) {
      return showError(o, st, cache: cache);
    }, loading: () {
      return showLoading(cache: cache);
    });
  }
}
