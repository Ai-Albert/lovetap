import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lovetap/custom_widgets/show_alert_dialogue.dart';

Future showExceptionAlertDialog(
    BuildContext context, {
      required String title,
      required Exception exception,
    }) =>
    showAlertDialog(
      context,
      title: title,
      content: _message(exception),
      defaultActionText: 'OK',
    );

String _message(Exception exception) {
  if (exception is FirebaseException) {
    return exception.message!;
  }
  return exception.toString();
}