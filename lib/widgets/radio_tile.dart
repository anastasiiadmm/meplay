import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class RadioTile extends StatelessWidget {
  final Channel channel;
  final void Function() onTap;

  RadioTile({
    Key key,
    @required this.channel,
    this.onTap,
  }): super(key: key);

  Widget get _title {
    return Text(
      channel.radioName,
      maxLines: 1,
      style: AppFonts.itemTitle,
    );
  }

  Widget get _text {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Text(
        channel.radioFM,
        style: AppFonts.itemTextSecondary,
        maxLines: 1,
      ),
    );
  }

  Widget get _content {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.decorativeGray),
        ),
      ),
      child: SizedBox(
        height: 59,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _title,
              _text,
            ],
          ),
        ),
      ),
    );
  }

  Widget _wrapTap(Widget content) {
    if(onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(double.infinity, 59),
      child: _wrapTap(
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: _content,
        ),
      ),
    ) ;
  }
}
