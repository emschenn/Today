import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(48);

  final String? title;
  final Widget? leading;
  final Widget? action;
  final double? elevation;
  final bool? centerTitle;

  const CustomAppBar(
      {Key? key,
      this.elevation,
      this.centerTitle,
      this.title,
      this.leading,
      this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 58,
      elevation: elevation ?? 0.5,
      backgroundColor: Colors.white,
      centerTitle: centerTitle,
      leading: (leading != null) ? leading : const SizedBox(),
      actions: [if (action != null) action!],
      title: Text(title ?? '', style: Theme.of(context).textTheme.headline1),
    );
  }
}
