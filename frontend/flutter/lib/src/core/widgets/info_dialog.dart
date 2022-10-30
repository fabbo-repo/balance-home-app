import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String dialogTitle;
  final String dialogDescription;
  final String confirmationText;
  final String cancelText;
  final void Function()? onConfirmation;
  final void Function()? onCancel;

  const InfoDialog({
    required this.dialogTitle, 
    required this.dialogDescription, 
    required this.confirmationText, 
    required this.cancelText, 
    this.onConfirmation, 
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
          child: Text(confirmationText),
          onPressed: () {
            if (onConfirmation != null) {
              onConfirmation!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
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