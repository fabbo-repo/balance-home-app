import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TextCheckBox extends StatefulWidget {
  final String title;
  final Color fillColor;
  final Function(bool?)? onChanged;
  bool isChecked;

  TextCheckBox(
      {required this.title,
      this.onChanged,
      this.fillColor = const Color.fromARGB(255, 70, 70, 70),
      this.isChecked = false,
      Key? key})
      : super(key: key);

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
                widget.isChecked = !widget.isChecked;
                if (widget.onChanged != null) {
                  widget.onChanged!(widget.isChecked);
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
  Widget checkBox(Color fillColor) {
    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith((_) => fillColor),
      value: widget.isChecked,
      onChanged: (bool? value) {
        setState(() {
          widget.isChecked = value!;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
    );
  }
}
