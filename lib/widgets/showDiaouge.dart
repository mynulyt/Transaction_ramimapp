// lib/admin_panel/pin_dialog.dart
import 'package:flutter/material.dart';

Future<String?> showPinDialog(BuildContext context) async {
  final TextEditingController _pinController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter Admin PIN'),
      content: TextField(
        controller: _pinController,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'PIN'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _pinController.text),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
