import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DropdownPickerField extends StatefulWidget {
  final String name;
  final List<String> items;
  final bool readOnly;
  final void Function(String?)? onChanged;
  String initialValue;

  DropdownPickerField(
      {required this.name,
      required this.initialValue,
      required this.items,
      this.readOnly = false,
      this.onChanged,
      super.key});

  @override
  State<DropdownPickerField> createState() => _DropdownPickerFieldState();
}

class _DropdownPickerFieldState extends State<DropdownPickerField> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 15, 0, 20),
        width: 200,
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
            value: widget.initialValue,
            onChanged: widget.readOnly
                ? null
                : (String? value) {
                    setState(() {
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                      widget.initialValue = value!;
                    });
                  },
            items: widget.items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}
