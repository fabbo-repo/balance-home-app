import 'package:balance_home_app/src/core/utils/type_util.dart';
import 'package:balance_home_app/src/core/utils/widget_utils.dart';
import 'package:balance_home_app/src/features/balance/domain/entities/balance_type_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BalanceTypeDropdownPicker extends StatefulWidget {
  final String name;
  final List<BalanceTypeEntity> items;
  final bool readOnly;
  final void Function(BalanceTypeEntity?)? onChanged;
  final AppLocalizations appLocalizations;
  final ValueNotifier<BalanceTypeEntity> balanceTypeState;

  BalanceTypeDropdownPicker(
      {required this.name,
      required BalanceTypeEntity initialValue,
      required this.items,
      required this.appLocalizations,
      this.readOnly = false,
      this.onChanged,
      super.key})
      : balanceTypeState = ValueNotifier<BalanceTypeEntity>(initialValue);

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
          DropdownButton<String>(
            value: widget.balanceTypeState.value.name,
            onChanged: widget.readOnly
                ? null
                : (String? name) {
                    for (final value in widget.items) {
                      if (value.name == name) {
                        if (widget.onChanged != null) {
                          widget.onChanged!(value);
                        }
                        setState(() {
                          widget.balanceTypeState.value = value;
                        });
                        return;
                      }
                    }
                  },
            items: widget.items
                .map<DropdownMenuItem<String>>((BalanceTypeEntity value) {
              return DropdownMenuItem<String>(
                value: value.name,
                child: Row(
                  children: [
                    Image.network(
                      value.image,
                      width: 24,
                      height: 24,
                    ),
                    horizontalSpace(),
                    Text(
                      TypeUtil.balanceTypeToString(
                          value.name, widget.appLocalizations),
                      overflow: TextOverflow.ellipsis,
                    ),
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
