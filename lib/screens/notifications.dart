import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/local_notification_helper.dart';
import '../widgets/bottomNavBar.dart';
import '../theme.dart';
import '../widgets/modals.dart';


class NotificationListScreen extends StatefulWidget {
  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<PendingNotificationRequest> _notifications = [];

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  Future<void> _getNotifications() async {
    List<PendingNotificationRequest> notifications =
      await LocalNotificationHelper.instance.list();
    if(notifications == null) notifications = [];
    setState(() {
      _notifications = notifications;
    });
  }

  void _back() {
    Navigator.of(context).pop();
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.megaPurple,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      leading: IconButton(
        onPressed: _back,
        icon: AppIcons.back,
      ),
      title: Text('Уведомления', style: AppFonts.screenTitle),
    );
  }

  Widget get _bottomBar => BottomNavBar();

  void _cancelModal(PendingNotificationRequest request) {
    confirmModal(
      context: context,
      title: Text("Вы уверены что хотите удалить это уведомление?"),
      action: () => _cancel(request),
    );
  }

  Future<void> _cancel(PendingNotificationRequest request) async {
    await LocalNotificationHelper.instance.cancel(request.id);
    setState(() {
      _notifications.remove(request);
    });
  }

  Widget _tileBuilder(BuildContext context, int index) {
    PendingNotificationRequest request = _notifications[index];
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      title: Text(
        request.title,
        style: AppFonts.channelName,
      ),
      subtitle: Text(
        request.body,
        style: AppFonts.programName,
      ),
      trailing: IconButton(
      icon: AppIcons.trashRed,
      onPressed: () => _cancelModal(request),
    ),
    );
  }

  Widget get _body => ListView.separated(
    itemBuilder: _tileBuilder,
    separatorBuilder: (BuildContext context, int id) => Divider(height: 0,),
    itemCount: _notifications.length,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomBar,
    );
  }
}
