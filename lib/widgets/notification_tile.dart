import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models.dart';
import '../theme.dart';
import 'channel_logo.dart';


class NotificationTile extends StatelessWidget {
  final PendingNotificationRequest notification;
  final void Function() onTap;
  final void Function() onDelete;
  final Map<String, dynamic> _data;

  NotificationTile({
    Key key,
    @required this.notification,
    this.onTap,
    this.onDelete,
  }): this._data = jsonDecode(notification.payload),
        super(key: key);

  Future<Channel> get _channel {
    return Channel.getChannel(_data['channelId'], ChannelType.tv);
  }

  Widget get _logo {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: FutureBuilder<Channel>(
        future: _channel,
        builder: (BuildContext context, snapshot) {
          if(snapshot.hasData) {
            return ChannelLogo(
              size: LogoSize.small,
              channel: snapshot.data,
            );
          } else {
            return SizedBox(
              width: LogoSize.small.size,
            );
          }
        },
      )
    );
  }

  Widget get _time {
    return Text(
      _data['startTime'],
      style: AppFontsV2.itemTitle,
    );
  }

  Widget get _title {
    return Text(
      _data['channelName'],
      style: AppFontsV2.itemTextSecondary,
    );
  }

  Widget get _program {
    return Text(
      _data['_program'],
      style: AppFontsV2.itemTitle,
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
        height: 99,
        child: Padding(
          padding: EdgeInsets.only(right: 50, bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _time,
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
      preferredSize: Size(double.infinity, 99),
      child: Stack(
        children: [
          _wrapTap(
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logo,
                  Expanded(
                    child: _texts,
                  ),
                ],
              ),
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
