import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(48);

  final String? title;
  final Widget? leading;
  final Widget? action;

  const CustomAppBar({Key? key, this.title, this.leading, this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      leading: (leading != null) ? leading : const SizedBox(),
      actions: [if (action != null) action!],
      title: Text(title ?? '', style: Theme.of(context).textTheme.headline1),
    );
  }
}
