import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String dialogTitle;
  final String dialogDescription;
  final String cancelText;
  final void Function()? onCancel;

  const ErrorDialog({
    required this.dialogTitle, 
    required this.dialogDescription, 
    required this.cancelText, 
    this.onCancel,
    super.key, 
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(dialogTitle),
      content: Text(dialogDescription),
      actions: <Widget>[
        ElevatedButton(
          child: Text(cancelText),
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}