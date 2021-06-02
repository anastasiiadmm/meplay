import 'package:flutter/material.dart';
import '../theme.dart';


class TabSwitch extends StatefulWidget {
  static const int left = 0;
  static const int right = 1;

  final Widget leftTab;
  final Widget rightTab;
  final String leftLabel;
  final String rightLabel;
  final int initialActive;

  TabSwitch({
    Key key,
    @required this.leftTab,
    @required this.rightTab,
    this.leftLabel,
    this.rightLabel,
    this.initialActive: left,
  }): super(key: key);

  @override
  _TabSwitchState createState() => _TabSwitchState();
}

class _TabSwitchState extends State<TabSwitch> {
  int _active;
  PageController _controller;

  @override
  void initState(){
    super.initState();
    _active = widget.initialActive;
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget get _switch {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: AppColorsV2.blockBg,
              ),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            color: _active == TabSwitch.left
                ? AppColorsV2.text
                : AppColorsV2.item,
          ),
          child: Text(
            widget.leftLabel ?? '',
            style: _active == TabSwitch.left
                ? AppFontsV2.tabSwitchActive
                : AppFontsV2.tabSwitch,
            textAlign: TextAlign.center,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            color: _active == TabSwitch.left
                ? AppColorsV2.text
                : AppColorsV2.item,
          ),
          child: Text(
            widget.rightLabel ?? '',
            style: _active == TabSwitch.left
                ? AppFontsV2.tabSwitchActive
                : AppFontsV2.tabSwitch,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget get _tabs {
    return Padding(
      padding: EdgeInsets.only(top: 32),
      child: PageView(
        controller: _controller,
        children: [
          widget.leftTab,
          widget.rightTab,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _switch,
        Expanded(
          child: _tabs,
        )
      ],
    );
  }
}
