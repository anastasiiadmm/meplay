import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';


class NewsTile extends StatelessWidget {
  final News newsItem;
  final void Function() onTap;

  NewsTile({
    Key key,
    @required this.newsItem,
    this.onTap,
  }): super(key: key);

  Widget get _title {
    return Text(
      '${newsItem.title} ${newsItem.text}',
      maxLines: 2,
      style: newsItem.isRead
          ? AppFontsV2.textPrimaryMute
          : AppFontsV2.textPrimary,
    );
  }

  Widget get _content {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColorsV2.decorativeGray),
        ),
      ),
      child: SizedBox(
        height: 61,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12, right: 16),
            child: _title,
          ),
        )
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
      preferredSize: Size(double.infinity, 61),
      child: _wrapTap(
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: _content,
        ),
      ),
    ) ;
  }
}
