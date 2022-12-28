import 'package:flutter/material.dart';

class TextCheckBox extends StatefulWidget {
  final String title;
  final Color fillColor;
  final Function(bool?)? onChanged;

  const TextCheckBox(
      {required this.title,
      this.onChanged,
      this.fillColor = const Color.fromARGB(255, 70, 70, 70),
      Key? key})
      : super(key: key);

  @override
  State<TextCheckBox> createState() => _TextCheckBoxState();
}

class _TextCheckBoxState extends State<TextCheckBox> {
  bool isChecked = false;

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
                isChecked = !isChecked;
                if (widget.onChanged != null) {
                  widget.onChanged!(isChecked);
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
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
    );
  }
}
