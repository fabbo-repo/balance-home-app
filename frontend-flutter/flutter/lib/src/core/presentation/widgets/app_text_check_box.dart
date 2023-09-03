import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextCheckBox extends StatefulWidget {
  final String title;
  final Color? fillColor;
  final Function(bool?)? onChanged;
  final isCheckedState = ValueNotifier<bool>(false);

  AppTextCheckBox(
      {required this.title,
      this.onChanged,
      this.fillColor,
      isChecked = false,
      Key? key})
      : super(key: key) {
    isCheckedState.value = isChecked;
  }

  @override
  State<AppTextCheckBox> createState() => _AppTextCheckBoxState();
}

class _AppTextCheckBoxState extends State<AppTextCheckBox> {
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
                widget.isCheckedState.value = !widget.isCheckedState.value;
                if (widget.onChanged != null) {
                  widget.onChanged!(widget.isCheckedState.value);
                }
              });
            },
            child: Text(
              widget.title,
              style:
                  GoogleFonts.openSans(color: widget.fillColor, fontSize: 14),
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
      value: widget.isCheckedState.value,
      onChanged: (bool? value) {
        setState(() {
          widget.isCheckedState.value = value!;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
    );
  }
}
