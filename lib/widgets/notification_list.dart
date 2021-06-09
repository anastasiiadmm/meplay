import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_tile.dart';


class NotificationList extends StatelessWidget {
  final List<PendingNotificationRequest> notifications;
  final void Function(PendingNotificationRequest notification) onDelete;

  NotificationList({
    Key key,
    @required this.notifications,
    this.onDelete,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (BuildContext context, int id) {
        PendingNotificationRequest notification = notifications[id];
        return Padding(
          padding: id == 0
              ? EdgeInsets.symmetric(vertical: 12)
              : EdgeInsets.only(bottom: 12),
          child: NotificationTile(
            notification: notification,
            onTap: null,  // TODO: open channel from the link.
            onDelete: () => onDelete(notification),
          ),
        );
      },
    );
  }
}
