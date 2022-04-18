import 'package:flutter/material.dart';

class AnimatedDialog extends StatelessWidget {
  final bool isShow;
  final Widget child;
  final Color backgroundColor;

  const AnimatedDialog(
      {Key? key,
      required this.isShow,
      required this.backgroundColor,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return AnimatedOpacity(
        opacity: isShow ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Center(
            child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 80),
                width: 160,
                height: 120,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(18.0)),
                child: child)));
  }
}
