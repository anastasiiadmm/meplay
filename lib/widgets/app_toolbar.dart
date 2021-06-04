import 'package:flutter/material.dart';
import '../theme.dart';


// TODO: add bottom line on design

class AppToolBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final void Function() back;
  final List<Widget> actions;

  AppToolBar({
    Key key,
    this.title,
    this.subtitle,
    this.back,
    this.actions,
  }): super(key: key);

  @override
  Size get preferredSize => Size(double.infinity, subtitle == null ? 44 : 60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      backgroundColor: AppColorsV2.item,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () => back == null ? Navigator.of(context).pop() : back(),
        icon: AppIconsV2.chevronLeft,
        constraints: BoxConstraints(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            this.title,
            style: AppFonts.screenTitle,
          ),
          if(subtitle != null) Text(
            this.subtitle,
            style: AppFonts.screenSubTitle,
          ),
        ],
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}
