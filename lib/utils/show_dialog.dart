import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<Future> showAlertDialog({
  required BuildContext context,
  required String title,
  String? content,
  bool isCustomContent = false,
  Widget? contentWidget,
  String? cancelText,
  Function? cancelAction,
  required String confirmText,
  required Function confirmAction,
}) async {
  if (!Platform.isIOS) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.subtitle2),
        content: isCustomContent
            ? contentWidget!
            : Text(content!,
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .merge(const TextStyle(fontWeight: FontWeight.w500))),
        actions: <Widget>[
          if (cancelText != null)
            TextButton(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent)),
              child: Text(cancelText,
                  style: const TextStyle(color: Colors.black87)),
              onPressed: () {
                cancelAction!();
              },
            ),
          TextButton(
            style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent)),
            child: Text(
              confirmText,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () {
              confirmAction();
            },
          ),
        ],
      ),
    );
  }

  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: isCustomContent
          ? contentWidget!
          : Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(content!,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
      actions: <Widget>[
        if (cancelText != null)
          CupertinoDialogAction(
            child:
                Text(cancelText, style: const TextStyle(color: Colors.black87)),
            onPressed: () {
              cancelAction!();
            },
          ),
        CupertinoDialogAction(
          child: Text(
            confirmText,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500),
          ),
          onPressed: () {
            confirmAction();
          },
        ),
      ],
    ),
  );
}
