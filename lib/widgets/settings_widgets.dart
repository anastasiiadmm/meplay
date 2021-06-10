import 'package:flutter/material.dart';
import '../theme.dart';


class SettingsTitle extends StatelessWidget {
  final String text;

  @override
  SettingsTitle({
    Key key,
    @required this.text,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(text, style: AppFonts.settingsTitle),
    );
  }
}


class SettingsTile extends StatelessWidget {
  final String text;
  final void Function() onTap;
  final bool active;

  @override
  SettingsTile({
    Key key,
    @required this.text,
    this.onTap,
    this.active: false,
  }): super(key: key);

  Widget _wrapTap(Widget child) {
    if(onTap == null) return child;
    return InkWell(
      onTap: onTap,
      child: child,
    );
  }

  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blockBg,
      child: _wrapTap(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: AppFonts.textPrimary,
                ),
              ),
              if(active) Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppIcons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SettingsBlock<T> extends StatelessWidget {
  final void Function(T item) onTap;
  final List<T> items;
  final String Function(T item) getText;
  final String title;
  final bool Function(T item) isActive;

  @override
  SettingsBlock({
    Key key,
    @required this.title,
    this.items,
    this.getText,
    this.onTap,
    this.isActive,
  }): super(key: key);

  Widget build(BuildContext context) {
    List<Widget> tiles = [
      SettingsTitle(
        text: title,
      ),
    ];
    for(int i = 0; i < items.length; i++) {
      T item = items[i];
      Widget tile = SettingsTile(
        text: getText(item),
        onTap: () => onTap(item),
        active: isActive(item),
      );
      if(i > 0) tile = Padding(
        padding: EdgeInsets.only(top: 1),
        child: tile,
      );
      tiles.add(tile);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: tiles,
    );
  }
}
