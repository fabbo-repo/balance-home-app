import 'package:balance_home_app/config/app_colors.dart';
import 'package:balance_home_app/src/core/domain/failures/http_connection_failure.dart';
import 'package:balance_home_app/src/core/domain/failures/no_local_entity_failure.dart';
import 'package:balance_home_app/src/core/presentation/widgets/double_form_field.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_button.dart';
import 'package:balance_home_app/src/core/presentation/widgets/app_text_form_field.dart';
import 'package:balance_home_app/src/core/providers.dart';
import 'package:balance_home_app/src/core/utils/dialog_utils.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/account/domain/entities/account_entity.dart';
import 'package:balance_home_app/src/features/auth/domain/values/email.dart';
import 'package:balance_home_app/src/features/auth/domain/values/register_name.dart';
import 'package:balance_home_app/src/features/auth/providers.dart';
import 'package:balance_home_app/src/features/balance/domain/values/balance_quantity.dart';
import 'package:balance_home_app/src/features/currency/presentation/widgets/dropdown_picker_field.dart';
import 'package:balance_home_app/src/features/currency/providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart' as mm;

class AccountEditForm extends ConsumerStatefulWidget {
  @visibleForTesting
  final formKey = GlobalKey<FormState>();
  
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final expectedMonthlyBalanceController = TextEditingController();
  final expectedAnnualBalanceController = TextEditingController();
  
  final bool edit;
  final AccountEntity user;
  final cache = ValueNotifier<Widget>(Container());

  AccountEditForm({
    required this.edit,
    required this.user,
    super.key,
  });

  @override
  ConsumerState<AccountEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends ConsumerState<AccountEditForm> {
  UserName? username;
  UserEmail? email;
  BalanceQuantity? expectedMonthlyBalance;
  BalanceQuantity? expectedAnnualBalance;
  String? prefCoinType;
  Uint8List? imageBytes;
  String? imageType;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
    widget.usernameController.text = widget.usernameController.text.isEmpty
        ? widget.user.username
        : widget.usernameController.text;
    widget.emailController.text = widget.emailController.text.isEmpty
        ? widget.user.email
        : widget.emailController.text;
    widget.expectedMonthlyBalanceController.text =
        widget.expectedMonthlyBalanceController.text.isEmpty
            ? widget.user.expectedMonthlyBalance.toString().replaceAll(".", ",")
            : widget.expectedMonthlyBalanceController.text;
    widget.expectedAnnualBalanceController.text =
        widget.expectedAnnualBalanceController.text.isEmpty
            ? widget.user.expectedAnnualBalance.toString().replaceAll(".", ",")
            : widget.expectedAnnualBalanceController.text;
    username = UserName(appLocalizations, widget.usernameController.text);
    email = UserEmail(appLocalizations, widget.emailController.text);
    expectedMonthlyBalance = BalanceQuantity(
        appLocalizations,
        double.tryParse(
            widget.expectedMonthlyBalanceController.text.replaceAll(",", ".")));
    expectedAnnualBalance = BalanceQuantity(
        appLocalizations,
        double.tryParse(
            widget.expectedAnnualBalanceController.text.replaceAll(",", ".")));
    prefCoinType ??= widget.user.prefCoinType;

    final currencyTypes = ref.watch(currencyTypeListsControllerProvider);
    final userEdit = ref.watch(userEditControllerProvider);
    final userEditController = ref.read(userEditControllerProvider.notifier);
    // This is used to refresh page in case handle controller
    return userEdit.when(data: (_) {
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
          widget.cache.value = Form(
            key: widget.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  verticalSpace(),
                  CircleAvatar(
                      foregroundColor: AppColors.appBarBackgroundColor,
                      backgroundColor: AppColors.appBarBackgroundColor,
                      backgroundImage: imageBytes == null
                          ? Image.network(widget.user.image!).image
                          : Image.memory(imageBytes!).image,
                      radius: 50,
                      child: !widget.edit
                          ? null
                          : Container(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                iconSize: 30,
                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await updateImage();
                                  setState(() {});
                                },
                              ))),
                  verticalSpace(),
                  AppTextFormField(
                    readOnly: !widget.edit,
                    onChanged: (value) =>
                        username = UserName(appLocalizations, value),
                    title: appLocalizations.username,
                    validator: (value) => username?.validate,
                    maxCharacters: 15,
                    maxWidth: 400,
                    controller: widget.usernameController,
                  ),
                  verticalSpace(),
                  AppTextFormField(
                    readOnly: true,
                    onChanged: (value) =>
                        email = UserEmail(appLocalizations, value),
                    title: appLocalizations.emailAddress,
                    validator: (value) => email?.validate,
                    maxCharacters: 300,
                    maxWidth: 400,
                    controller: widget.emailController,
                  ),
                  verticalSpace(),
                  DoubleFormField(
                    readOnly: !widget.edit,
                    onChanged: (value) => expectedMonthlyBalance =
                        BalanceQuantity(appLocalizations, value),
                    title: appLocalizations.expectedMonthlyBalance,
                    validator: (value) => expectedMonthlyBalance?.validate,
                    maxWidth: 300,
                    controller: widget.expectedMonthlyBalanceController,
                  ),
                  verticalSpace(),
                  DoubleFormField(
                    readOnly: !widget.edit,
                    onChanged: (value) => expectedAnnualBalance =
                        BalanceQuantity(appLocalizations, value),
                    title: appLocalizations.expectedAnnualBalance,
                    validator: (value) => expectedAnnualBalance?.validate,
                    maxWidth: 300,
                    controller: widget.expectedAnnualBalanceController,
                  ),
                  verticalSpace(),
                  (currencyTypes.isNotEmpty)
                      ? DropdownPickerField(
                          readOnly: !widget.edit,
                          name: appLocalizations.currencyType,
                          initialValue: prefCoinType!,
                          items: currencyTypes.map((e) => e.code).toList(),
                          onChanged: (value) async {
                            if (value! == widget.user.prefCoinType) return;
                            (await userEditController.getExchange(
                                    widget.user.balance,
                                    widget.user.prefCoinType,
                                    value,
                                    appLocalizations))
                                .fold((failure) {
                              setState(() {
                                prefCoinType = widget.user.prefCoinType;
                              });
                              showErrorUserEditDialog(
                                  appLocalizations, failure.detail);
                            }, (newBalance) async {
                              if (await showCurrencyChangeAdviceDialog(
                                  appLocalizations, newBalance, value)) {
                                prefCoinType = value;
                              } else {
                                setState(() {
                                  prefCoinType = widget.user.prefCoinType;
                                });
                              }
                            });
                          })
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
                        if (username == null) return;
                        if (email == null) return;
                        if (expectedMonthlyBalance == null) return;
                        if (expectedAnnualBalance == null) return;
                        if (imageBytes != null) {
                          bool isImageOk = true;
                          (await userEditController.handleImage(
                                  imageBytes!, imageType!, appLocalizations))
                              .fold((failure) {
                            isImageOk = false;
                            showErrorUserEditDialog(
                                appLocalizations, failure.detail);
                          }, (_) => null);
                          if (!isImageOk) return;
                        }
                        (await userEditController.handle(
                                widget.user,
                                username!,
                                email!,
                                expectedMonthlyBalance!,
                                expectedAnnualBalance!,
                                prefCoinType!,
                                appLocalizations))
                            .fold((failure) {
                          showErrorUserEditDialog(
                              appLocalizations, failure.detail);
                        }, (entity) {
                          authController.refreshUserData();
                        });
                      },
                    ),
                ],
              ),
            ),
          );
          return widget.cache.value;
        });
      }, error: (error, _) {
        return showError(
            error: error,
            background: widget.cache.value,
            text: appLocalizations.genericError);
      }, loading: () {
        return showLoading(background: widget.cache.value);
      });
    }, error: (error, _) {
      return showError(
          error: error,
          background: widget.cache.value,
          text: appLocalizations.genericError);
    }, loading: () {
      return showLoading(background: widget.cache.value);
    });
  }

  @visibleForTesting
  Future<void> updateImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      imageBytes = result.files.single.bytes;
      imageType = mm.lookupMimeType(result.files.single.name) ?? "";
    }
  }
}
