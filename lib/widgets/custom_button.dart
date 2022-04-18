import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Function onClick;
  final double? width;

  const CustomButton(
      {Key? key,
      required this.onClick,
      required this.color,
      required this.textColor,
      this.width,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        textStyle: Theme.of(context).textTheme.button,
        primary: textColor,
        minimumSize: width == null ? const Size(120, 42) : Size(width!, 42),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
        ),
      ),
      onPressed: () {
        onClick();
      },
      child: Text(
        text,
      ),
    );
  }
}
