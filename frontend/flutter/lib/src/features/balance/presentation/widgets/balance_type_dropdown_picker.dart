import 'package:balance_home_app/src/core/utils/type_util.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class BalanceTypeDropdownPicker extends StatefulWidget {
  final String name;
  final List<BalanceTypeEntity> items;
  final bool readOnly;
  final void Function(BalanceTypeEntity?)? onChanged;
  final AppLocalizations appLocalizations;
  BalanceTypeEntity initialValue;

  BalanceTypeDropdownPicker(
      {required this.name,
      required this.initialValue,
      required this.items,
      required this.appLocalizations,
      this.readOnly = false,
      this.onChanged,
      super.key});

  @override
  State<BalanceTypeDropdownPicker> createState() =>
      _BalanceTypeDropdownPickerState();
}

class _BalanceTypeDropdownPickerState extends State<BalanceTypeDropdownPicker> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 15, 0, 20),
        width: 280,
        color: Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(200, 163, 163, 163)
            : const Color.fromARGB(198, 104, 104, 104),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
            child: Text(
              widget.name,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  fontSize: 15),
            ),
          ),
          DropdownButton<BalanceTypeEntity>(
            value: widget.initialValue,
            onChanged: widget.readOnly
                ? null
                : (BalanceTypeEntity? value) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                    setState(() {
                      widget.initialValue = value!;
                    });
                  },
            items: widget.items.map<DropdownMenuItem<BalanceTypeEntity>>(
                (BalanceTypeEntity value) {
              return DropdownMenuItem<BalanceTypeEntity>(
                value: value,
                child: Row(
                  children: [
                    Image.network(
                      value.image,
                      width: 20,
                      height: 20,
                    ),
                    horizontalSpace(),
                    Text(TypeUtil.balanceTypeToString(
                        value.name, widget.appLocalizations)),
                  ],
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}
