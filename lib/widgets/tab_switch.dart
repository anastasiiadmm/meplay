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

  void _switchTo(int id) {
    _controller.animateToPage(
      id,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() { _active = id; });
  }

  Widget _switchItem(String text, int id) {
    return GestureDetector(
      onTap: () => _switchTo(id),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: id == TabSwitch.left ? BorderRadius.only(
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          ) : BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
          color: _active == id ? AppColorsV2.text : AppColorsV2.item,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 4, 5, 6),
          child: Text(
            text ?? '',
            style: _active == id
                ? AppFontsV2.tabSwitchActive
                : AppFontsV2.tabSwitch,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        )
      ),
    );
  }

  Widget get _switch {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _switchItem(
              widget.leftLabel,
              TabSwitch.left,
            ),
          ),
          SizedBox(
            width: 1,
            child: ColoredBox(
              color: AppColorsV2.blockBg,
            ),
          ),
          Expanded(
            child: _switchItem(
              widget.rightLabel,
              TabSwitch.right,
            ),
          ),
        ],
      ),
    );
  }

  void _pageChanged(int id) {
    setState(() { _active = id; });
  }

  Widget get _tabs {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: PageView(
        controller: _controller,
        onPageChanged: _pageChanged,
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
      children: [
        _switch,
        Expanded(
          child: _tabs,
        )
      ],
    );
  }
}
