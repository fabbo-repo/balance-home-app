import 'package:balance_home_app/src/core/router.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/core/presentation/widgets/double_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
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
import 'package:balance_home_app/src/features/balance/presentation/widgets/balance_type_dropdown_picker.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:balance_home_app/src/features/currency/presentation/widgets/dropdown_picker_field.dart';
import 'package:balance_home_app/src/features/currency/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BalanceEditForm extends ConsumerStatefulWidget {
  @visibleForTesting
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final dateController = TextEditingController();

  final dateFormatter = DateFormat("dd/MM/yyyy");

  @visibleForTesting
  final bool edit;
  @visibleForTesting
  final BalanceEntity balance;

  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  @visibleForTesting
  final BalanceTypeMode balanceTypeMode;

  BalanceEditForm({
    required this.edit,
    required this.balance,
    required this.balanceTypeMode,
    super.key,
  });

  @override
  ConsumerState<BalanceEditForm> createState() => _BalanceEditFormState();
}

class _BalanceEditFormState extends ConsumerState<BalanceEditForm> {
  @visibleForTesting
  BalanceName? name;
  @visibleForTesting
  BalanceDescription? description;
  @visibleForTesting
  BalanceQuantity? quantity;
  @visibleForTesting
  BalanceDate? date;
  @visibleForTesting
  String? coinType;
  @visibleForTesting
  BalanceTypeEntity? balanceTypeEntity;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
    widget.nameController.text = widget.balance.name;
    widget.descriptionController.text = widget.balance.description;
    widget.quantityController.text =
        widget.balance.realQuantity.toString().replaceAll(".", ",");
    if (widget.dateController.text.isEmpty) {
      widget.dateController.text =
          widget.dateFormatter.format(widget.balance.date);
    }
    name = BalanceName(appLocalizations, widget.nameController.text);
    description =
        BalanceDescription(appLocalizations, widget.descriptionController.text);
    quantity = BalanceQuantity(appLocalizations,
        double.tryParse(widget.quantityController.text.replaceAll(",", ".")));
    date = BalanceDate(
        appLocalizations,
        DateTime(
            int.parse(widget.dateController.text.split("/")[2]),
            int.parse(widget.dateController.text.split("/")[1]),
            int.parse(widget.dateController.text.split("/")[0])));
    coinType ??= widget.balance.coinType;
    final balanceEditControllerProvider =
        widget.balanceTypeMode == BalanceTypeMode.expense
            ? expenseEditControllerProvider
            : revenueEditControllerProvider;
    final balanceListController =
        widget.balanceTypeMode == BalanceTypeMode.expense
            ? ref.read(expenseListControllerProvider.notifier)
            : ref.read(revenueListControllerProvider.notifier);
    final balanceTypeListControllerProvider =
        widget.balanceTypeMode == BalanceTypeMode.expense
            ? expenseTypeListControllerProvider
            : revenueTypeListControllerProvider;

    final balanceEditController =
        ref.read(balanceEditControllerProvider.notifier);

    final currencyTypes = ref.watch(currencyTypeListsControllerProvider);
    final balanceTypes = ref.watch(balanceTypeListControllerProvider);
    final balanceEdit = ref.watch(balanceEditControllerProvider);
    // This is used to refresh page in case handle controller
    return balanceEdit.when(data: (_) {
      return balanceTypes.when(data: (balanceTypes) {
        balanceTypeEntity ??= widget.balance.balanceType;
        return currencyTypes.when(data: (data) {
          return data.fold((failure) {
            if (failure is HttpConnectionFailure ||
                failure is NoLocalEntityFailure) {
              return showError(
                  icon: Icons.network_wifi_1_bar,
                  text: appLocalizations.noConnection);
            }
            return showError(
                background: widget.cache.value, text: failure.detail);
          }, (currencyTypes) {
            widget.cache.value = SingleChildScrollView(
              child: Form(
                key: widget.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      verticalSpace(),
                      AppTextFormField(
                        readOnly: !widget.edit,
                        onChanged: (value) =>
                            name = BalanceName(appLocalizations, value),
                        title: appLocalizations.balanceName,
                        validator: (value) => name?.validate,
                        maxCharacters: 40,
                        maxWidth: 500,
                        controller: widget.nameController,
                      ),
                      verticalSpace(),
                      AppTextFormField(
                        readOnly: !widget.edit,
                        onChanged: (value) => description =
                            BalanceDescription(appLocalizations, value),
                        title: appLocalizations.balanceDescription,
                        validator: (value) => description?.validate,
                        maxCharacters: 2000,
                        maxWidth: 500,
                        maxHeight: 400,
                        maxLines: 7,
                        multiLine: true,
                        showCounterText: true,
                        controller: widget.descriptionController,
                      ),
                      verticalSpace(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DoubleFormField(
                            readOnly: !widget.edit,
                            onChanged: (value) => quantity =
                                BalanceQuantity(appLocalizations, value),
                            title: appLocalizations.balanceQuantity,
                            validator: (value) => quantity?.validate,
                            maxWidth: 200,
                            controller: widget.quantityController,
                            align: TextAlign.end,
                          ),
                          (currencyTypes.isNotEmpty)
                              ? DropdownPickerField(
                                  readOnly: !widget.edit,
                                  initialValue: coinType!,
                                  items:
                                      currencyTypes.map((e) => e.code).toList(),
                                  width: 100,
                                  onChanged: (value) {
                                    coinType = value;
                                  })
                              : const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                ),
                        ],
                      ),
                      verticalSpace(),
                      AppTextFormField(
                          readOnly: !widget.edit,
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
                              date = BalanceDate(appLocalizations, newDate);
                              widget.dateController.text =
                                  widget.dateFormatter.format(newDate);
                            }
                          },
                          textAlign: TextAlign.center,
                          controller: widget.dateController,
                          title: appLocalizations.balanceDate,
                          validator: (value) => date?.validate,
                          maxWidth: 200),
                      verticalSpace(),
                      (balanceTypes.isNotEmpty)
                          ? BalanceTypeDropdownPicker(
                              readOnly: !widget.edit,
                              name: appLocalizations.balanceType,
                              initialValue: balanceTypeEntity!,
                              items: balanceTypes,
                              onChanged: (value) {
                                balanceTypeEntity = value!;
                              },
                              appLocalizations: appLocalizations,
                            )
                          : Text(appLocalizations.genericError),
                      verticalSpace(),
                      if (widget.edit)
                        AppTextButton(
                          text: appLocalizations.confirmation,
                          width: 160,
                          height: 50,
                          onPressed: () async {
                            if (widget.formKey.currentState == null ||
                                !widget.formKey.currentState!.validate()) {
                              return;
                            }
                            if (name == null) return;
                            if (description == null) return;
                            if (quantity == null) return;
                            if (date == null) return;
                            (await balanceEditController.handle(
                                    widget.balance.id!,
                                    name!,
                                    description!,
                                    quantity!,
                                    date!,
                                    coinType!,
                                    balanceTypeEntity!,
                                    appLocalizations))
                                .fold((failure) {
                              showErrorBalanceEditDialog(appLocalizations,
                                  failure.detail, widget.balanceTypeMode);
                            }, (entity) {
                              router.goNamed(widget.balanceTypeMode ==
                                      BalanceTypeMode.expense
                                  ? BalanceView.routeExpensePath
                                  : BalanceView.routeRevenuePath);
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
            return widget.cache.value;
          });
        }, error: (error, _) {
          return showError(error: error, background: widget.cache.value);
        }, loading: () {
          return showLoading(background: widget.cache.value);
        });
      }, error: (error, _) {
        return showError(error: error, background: widget.cache.value);
      }, loading: () {
        return showLoading(background: widget.cache.value);
      });
    }, error: (error, _) {
      return showError(error: error, background: widget.cache.value);
    }, loading: () {
      return showLoading(background: widget.cache.value);
    });
  }
}
