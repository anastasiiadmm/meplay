import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import 'channel_logo.dart';


class FavoritesTile extends StatelessWidget {
  final Channel channel;
  final void Function() onTap;
  final void Function() onDelete;

  FavoritesTile({
    Key key,
    @required this.channel,
    this.onTap,
    this.onDelete,
  }): super(key: key);

  Widget get _logo {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: ChannelLogo(
        size: LogoSize.small,
        channel: channel,
      ),
    );
  }

  Widget get _title {
    return Text(
      channel.name,
      style: AppFontsV2.itemTitle,
    );
  }

  Widget get _program {
    return FutureBuilder<Program>(
      future: channel.currentProgram,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            snapshot.data == null ? '' : snapshot.data.timeTitle,
            style: AppFontsV2.itemTextSecondary,
            maxLines: 2,
          ),
        );
      },
    );
  }

  Widget get _texts {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColorsV2.decorativeGray),
        ),
      ),
      child: SizedBox(
        height: 77,
        child: Padding(
          padding: EdgeInsets.only(right: 50, bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _title,
              _program,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _delete {
    return IconButton(
      constraints: BoxConstraints(),
      padding: EdgeInsets.zero,
      icon: AppIconsV2.delete,
      onPressed: onDelete,
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
      preferredSize: Size(double.infinity, 77),
      child: Stack(
        children: [
          _wrapTap(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _logo,
                Expanded(
                  child: _texts,
                ),
              ],
            ),
          ),
          Positioned(
            child: _delete,
            top: 0,
            right: 16,
          ),
        ],
      ),
    ) ;
  }
}
