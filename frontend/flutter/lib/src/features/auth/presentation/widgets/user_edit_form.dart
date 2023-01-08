import 'package:balance_home_app/config/app_colors.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart' as mm;

class UserEditForm extends ConsumerStatefulWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _expectedMonthlyBalanceController = TextEditingController();
  final _expectedAnnualBalanceController = TextEditingController();
  final bool edit;
  final UserEntity user;

  UserEditForm({
    required this.edit,
    required this.user,
    super.key,
  });

  @override
  ConsumerState<UserEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends ConsumerState<UserEditForm> {
  UserName? _username;
  UserEmail? _email;
  BalanceQuantity? _expectedMonthlyBalance;
  BalanceQuantity? _expectedAnnualBalance;
  String? _prefCoinType;
  Uint8List? _imageBytes;
  String? _imageType;
  Widget cache = Container();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = ref.watch(appLocalizationsProvider);
    final authController = ref.read(authControllerProvider.notifier);
    widget._usernameController.text = widget._usernameController.text.isEmpty
        ? widget.user.username
        : widget._usernameController.text;
    widget._emailController.text = widget._emailController.text.isEmpty
        ? widget.user.email
        : widget._emailController.text;
    widget._expectedMonthlyBalanceController.text =
        widget._expectedMonthlyBalanceController.text.isEmpty
            ? widget.user.expectedMonthlyBalance.toString().replaceAll(".", ",")
            : widget._expectedMonthlyBalanceController.text;
    widget._expectedAnnualBalanceController.text =
        widget._expectedAnnualBalanceController.text.isEmpty
            ? widget.user.expectedAnnualBalance.toString().replaceAll(".", ",")
            : widget._expectedAnnualBalanceController.text;
    _username = UserName(appLocalizations, widget._usernameController.text);
    _email = UserEmail(appLocalizations, widget._emailController.text);
    _expectedMonthlyBalance = BalanceQuantity(
        appLocalizations,
        double.tryParse(widget._expectedMonthlyBalanceController.text
            .replaceAll(",", ".")));
    _expectedAnnualBalance = BalanceQuantity(
        appLocalizations,
        double.tryParse(
            widget._expectedAnnualBalanceController.text.replaceAll(",", ".")));
    _prefCoinType ??= widget.user.prefCoinType;

    final coinTypes = ref.watch(coinTypeListsControllerProvider);
    final userEdit = ref.watch(userEditControllerProvider);
    final userEditController = ref.read(userEditControllerProvider.notifier);
    // This is used to refresh page in case handle controller
    return userEdit.when(data: (_) {
      return coinTypes.when(data: (coinTypes) {
        cache = SingleChildScrollView(
          child: Form(
            key: widget._formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  verticalSpace(),
                  CircleAvatar(
                      foregroundColor: AppColors.appBarBackgroundColor,
                      backgroundColor: AppColors.appBarBackgroundColor,
                      backgroundImage: _imageBytes == null
                          ? NetworkImage(widget.user.image!)
                          : Image.memory(_imageBytes!).image,
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
                  CustomTextFormField(
                    readOnly: !widget.edit,
                    onChanged: (value) =>
                        _username = UserName(appLocalizations, value),
                    title: appLocalizations.username,
                    validator: (value) => _username?.validate,
                    maxCharacters: 15,
                    maxWidth: 400,
                    controller: widget._usernameController,
                  ),
                  verticalSpace(),
                  CustomTextFormField(
                    readOnly: true,
                    onChanged: (value) =>
                        _email = UserEmail(appLocalizations, value),
                    title: appLocalizations.emailAddress,
                    validator: (value) => _email?.validate,
                    maxCharacters: 300,
                    maxWidth: 400,
                    controller: widget._emailController,
                  ),
                  verticalSpace(),
                  CustomDoubleFormField(
                    readOnly: !widget.edit,
                    onChanged: (value) => _expectedMonthlyBalance =
                        BalanceQuantity(appLocalizations, value),
                    title: appLocalizations.expectedMonthlyBalance,
                    validator: (value) => _expectedMonthlyBalance?.validate,
                    maxWidth: 300,
                    controller: widget._expectedMonthlyBalanceController,
                  ),
                  verticalSpace(),
                  CustomDoubleFormField(
                    readOnly: !widget.edit,
                    onChanged: (value) => _expectedAnnualBalance =
                        BalanceQuantity(appLocalizations, value),
                    title: appLocalizations.expectedAnnualBalance,
                    validator: (value) => _expectedAnnualBalance?.validate,
                    maxWidth: 300,
                    controller: widget._expectedAnnualBalanceController,
                  ),
                  verticalSpace(),
                  (coinTypes.isNotEmpty)
                      ? DropdownPickerField(
                          readOnly: !widget.edit,
                          name: appLocalizations.coinType,
                          initialValue: _prefCoinType!,
                          items: coinTypes.map((e) => e.code).toList(),
                          onChanged: (value) {
                            _prefCoinType = value;
                          })
                      : Text(appLocalizations.genericError),
                  verticalSpace(),
                  if (widget.edit)
                    CustomTextButton(
                      text: appLocalizations.confirmation,
                      width: 160,
                      height: 50,
                      onPressed: () async {
                        if (widget._formKey.currentState == null ||
                            !widget._formKey.currentState!.validate()) {
                          return;
                        }
                        if (_username == null) return;
                        if (_email == null) return;
                        if (_expectedMonthlyBalance == null) return;
                        if (_expectedAnnualBalance == null) return;
                        if (_imageBytes != null) {
                          bool isImageOk = true;
                          (await userEditController.handleImage(
                                  _imageBytes!, _imageType!, appLocalizations))
                              .fold((l) {
                            isImageOk = false;
                            showErrorUserEditDialog(appLocalizations, l.error);
                          }, (r) => null);
                          if (!isImageOk) return;
                        }
                        (await userEditController.handle(
                                widget.user,
                                _username!,
                                _email!,
                                _expectedMonthlyBalance!,
                                _expectedAnnualBalance!,
                                _prefCoinType!,
                                appLocalizations))
                            .fold((l) {
                          showErrorUserEditDialog(appLocalizations, l.error);
                        }, (entity) {
                          navigatorKey.currentContext!
                              .goNamed(StatisticsView.routeName);
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

  @visibleForTesting
  Future<void> updateImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      _imageBytes = result.files.single.bytes;
      _imageType = mm.lookupMimeType(result.files.single.name) ?? "";
    }
  }
}
