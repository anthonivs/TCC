import 'package:flutter/material.dart';

class MessageUtils {
  static void showSuccess(BuildContext context, String message) {
    _showMessage(context, message, Colors.green);
  }

  static void showError(BuildContext context, String message) {
    _showMessage(context, message, Colors.red);
  }

  static void showInfo(BuildContext context, String message) {
    _showMessage(context, message, Colors.blue);
  }

  static void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}