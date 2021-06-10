import 'package:flutter/material.dart';
import 'app_icon_button.dart';
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
      backgroundColor: AppColors.item,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 50,
      leading: AppIconButton(
        onPressed: () => back == null ? Navigator.of(context).pop() : back(),
        icon: AppIcons.chevronLeft,
        padding: EdgeInsets.all(8),
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
            style: AppFonts.itemTextSecondary,
          ),
        ],
      ),
      centerTitle: true,
      actions: actions,
    );
  }
}
