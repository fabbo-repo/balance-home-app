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
import 'package:balance_home_app/src/features/currency/presentation/widgets/dropdown_picker_field.dart';
import 'package:balance_home_app/src/features/currency/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BalanceCreateForm extends ConsumerStatefulWidget {
  @visibleForTesting
  final formKey = GlobalKey<FormState>();
  @visibleForTesting
  final nameController = TextEditingController();
  @visibleForTesting
  final descriptionController = TextEditingController();
  @visibleForTesting
  final quantityController = TextEditingController();
  @visibleForTesting
  final dateController = TextEditingController();

  @visibleForTesting
  final cache = ValueNotifier<Widget>(Container());

  @visibleForTesting
  final BalanceTypeMode balanceTypeMode;

  BalanceCreateForm({
    required this.balanceTypeMode,
    super.key,
  });

  @override
  ConsumerState<BalanceCreateForm> createState() => _BalanceCreateFormState();
}

class _BalanceCreateFormState extends ConsumerState<BalanceCreateForm> {
  @visibleForTesting
  BalanceName? name;
  @visibleForTesting
  BalanceDescription? description;
  @visibleForTesting
  BalanceQuantity? quantity;
  @visibleForTesting
  BalanceDate? date;
  @visibleForTesting
  String? currencyType;
  @visibleForTesting
  BalanceTypeEntity? balanceTypeEntity;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
    name = BalanceName(appLocalizations, widget.nameController.text);
    description =
        BalanceDescription(appLocalizations, widget.descriptionController.text);
    quantity = BalanceQuantity(appLocalizations,
        double.tryParse(widget.quantityController.text.replaceAll(",", ".")));
    date = BalanceDate(
        appLocalizations,
        widget.dateController.text.isNotEmpty
            ? DateTime(
                int.parse(widget.dateController.text.split("/")[2]),
                int.parse(widget.dateController.text.split("/")[1]),
                int.parse(widget.dateController.text.split("/")[0]))
            : DateTime.now());
    if (widget.dateController.text.isEmpty) {
      widget.dateController.text =
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
    }
    final balanceCreateControllerProvider =
        widget.balanceTypeMode == BalanceTypeMode.expense
            ? expenseCreateControllerProvider
            : revenueCreateControllerProvider;
    final balanceListController =
        widget.balanceTypeMode == BalanceTypeMode.expense
            ? ref.read(expenseListControllerProvider.notifier)
            : ref.read(revenueListControllerProvider.notifier);
    final balanceTypeListControllerProvider =
        widget.balanceTypeMode == BalanceTypeMode.expense
            ? expenseTypeListControllerProvider
            : revenueTypeListControllerProvider;

    final balanceCreateController =
        ref.read(balanceCreateControllerProvider.notifier);

    final user = ref.watch(authControllerProvider);
    final balanceCreate = ref.watch(balanceCreateControllerProvider);
    final coinTypes = ref.watch(currencyTypeListsControllerProvider);
    final balanceTypes = ref.watch(balanceTypeListControllerProvider);
    return user.when(data: (user) {
      currencyType ??= user!.prefCoinType;
      // This is used to refresh page in case handle controller
      return balanceCreate.when(data: (_) {
        return balanceTypes.when(data: (balanceTypes) {
          balanceTypeEntity ??= balanceTypes[0];
          return coinTypes.when(data: (currencyTypes) {
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
                                  initialValue: currencyType!,
                                  items:
                                      currencyTypes.map((e) => e.code).toList(),
                                  width: 100,
                                  onChanged: (value) {
                                    currencyType = value;
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
                              date = BalanceDate(appLocalizations, newDate);
                              widget.dateController.text =
                                  "${newDate.day}/${newDate.month}/${newDate.year}";
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
                      AppTextButton(
                        width: 140,
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
                          (await balanceCreateController.handle(
                                  name!,
                                  description!,
                                  quantity!,
                                  date!,
                                  currencyType!,
                                  balanceTypeEntity!,
                                  appLocalizations))
                              .fold((failure) {
                            showErrorBalanceCreationDialog(appLocalizations,
                                failure.detail, widget.balanceTypeMode);
                          }, (entity) {
                            navigatorKey.currentContext!.go(
                                widget.balanceTypeMode ==
                                        BalanceTypeMode.expense
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
            return widget.cache.value;
          }, error: (o, st) {
            return showError(o, st, background: widget.cache.value);
          }, loading: () {
            return showLoading(background: widget.cache.value);
          });
        }, error: (o, st) {
          return showError(o, st, background: widget.cache.value);
        }, loading: () {
          return showLoading(background: widget.cache.value);
        });
      }, error: (o, st) {
        return showError(o, st, background: widget.cache.value);
      }, loading: () {
        return showLoading(background: widget.cache.value);
      });
    }, error: (o, st) {
      return showError(o, st, background: widget.cache.value);
    }, loading: () {
      return showLoading(background: widget.cache.value);
    });
  }
}
