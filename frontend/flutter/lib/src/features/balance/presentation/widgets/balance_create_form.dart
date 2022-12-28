import 'package:balance_home_app/config/app_layout.dart';
import 'package:balance_home_app/src/core/presentation/widgets/simple_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_entity.dart';
import 'package:balance_home_app/src/features/balance/domain/repositories/balance_type_mode.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_date.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_description.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_name.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:balance_home_app/src/features/balance/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class BalanceCreateForm extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  BalanceName? _name;
  BalanceDescription? _description;
  BalanceQuantity? _quantity;
  BalanceDate? _date;
  final BalanceTypeMode balanceTypeMode;

  BalanceCreateForm({
    required this.balanceTypeMode,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final balanceCreateControllerProvider =
        (balanceTypeMode == BalanceTypeMode.expense)
            ? expenseCreateControllerProvider
            : revenueCreateControllerProvider;
    final balanceListControllerProvider =
        (balanceTypeMode == BalanceTypeMode.expense)
            ? expenseListControllerProvider
            : revenueListControllerProvider;

    ref.listen<AsyncValue<BalanceEntity?>>(balanceCreateControllerProvider,
        (previous, next) {
      next.maybeWhen(
        data: (data) {
          if (data == null) return;
          ref.read(balanceListControllerProvider.notifier).addBalance(data);
          Navigator.pop(context);
        },
        orElse: () {},
      );
    });

    final res = ref.watch(balanceCreateControllerProvider);
    final errorText = res.maybeWhen(
      error: (error, stackTrace) => error.toString(),
      orElse: () => null,
    );

    final isLoading = res.maybeWhen(
      data: (_) => res.isRefreshing,
      loading: () => true,
      orElse: () => false,
    );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            space(),
            SimpleTextFormField(
              onChanged: (value) =>
                  _name = BalanceName(appLocalizations, value),
              title: appLocalizations.balanceName,
              error: errorText,
              validator: (value) => _name?.validate,
              readOnly: isLoading,
              maxCharacters: 40,
              maxWidth: 500,
              controller: _nameController,
            ),
            space(),
            SimpleTextFormField(
              onChanged: (value) =>
                  _description = BalanceDescription(appLocalizations, value),
              title: appLocalizations.balanceDescription,
              error: errorText,
              validator: (value) => _description?.validate,
              readOnly: isLoading,
              maxCharacters: 2000,
              maxWidth: 500,
              maxHeight: 400,
              maxLines: 7,
              multiLine: true,
              showCounterText: true,
              controller: _descriptionController,
            ),
            space(),
            SimpleTextFormField(
                onTap: () async {
                  // Below line stops keyboard from appearing
                  FocusScope.of(context).requestFocus(FocusNode());
                  // Show Date Picker Here
                  DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now());
                  if (date != null) {
                    _date = BalanceDate(appLocalizations, date);
                    _dateController.text =
                        "${date.day}/${date.month}/${date.year}";
                  }
                },
                controller: _dateController,
                title: appLocalizations.balanceDate,
                maxWidth: 200),
            space(),
            ElevatedButton(
              onPressed: isLoading ||
                      _formKey.currentState == null ||
                      !_formKey.currentState!.validate()
                  ? null
                  : () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      if (_name == null) return;
                      //ref
                      //    .read(balanceCreateControllerProvider.notifier)
                      //    .handle(_name!);
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(appLocalizations.create),
            ),
          ],
        ),
      ),
    );
  }

  @visibleForTesting
  Widget space() {
    return const SizedBox(
      height: AppLayout.genericPadding,
    );
  }
}
