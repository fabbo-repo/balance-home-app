import 'package:flutter/material.dart';

final isCheckedState = ValueNotifier<bool>(false);

class TextCheckBox extends StatefulWidget {
  final String title;
  final Color? fillColor;
  final Function(bool?)? onChanged;

  TextCheckBox(
      {required this.title,
      this.onChanged,
      this.fillColor,
      isChecked = false,
      Key? key})
      : super(key: key) {
    isCheckedState.value = isChecked;
  }

  @override
  State<TextCheckBox> createState() => _TextCheckBoxState();
}

class _TextCheckBoxState extends State<TextCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          checkBox(widget.fillColor),
          TextButton(
            onPressed: () {
              setState(() {
                isCheckedState.value = !isCheckedState.value;
                if (widget.onChanged != null) {
                  widget.onChanged!(isCheckedState.value);
                }
              });
            },
            child: Text(
              widget.title,
              style: TextStyle(color: widget.fillColor, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  @visibleForTesting
  Widget checkBox(Color? fillColor) {
    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith((_) => fillColor),
      value: isCheckedState.value,
      onChanged: (bool? value) {
        setState(() {
          isCheckedState.value = value!;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
    );
  }
}
