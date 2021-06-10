import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/tab_switch.dart';
import '../widgets/news_list.dart';
import '../widgets/notification_list.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/local_notification_helper.dart';
import '../utils/settings.dart';


class NotificationListScreen extends StatefulWidget {
  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<PendingNotificationRequest> _notifications = [];
  List<News> _news = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadNews();
  }

  Future<void> _loadNotifications() async {
    List<PendingNotificationRequest> notifications =
      await LocalNotificationHelper.instance.list();
    if(notifications == null) notifications = [];
    setState(() { _notifications = notifications; });
  }

  Future<void> _loadNews() async {
    List<News> news = await News.list;
    setState(() { _news = news; });
  }

  Widget get _appBar {
    return AppToolBar(
      title: locale(context).notifications,
    );
  }

  Widget get _bottomBar => BottomNavBar();

  void _cancelDialog(PendingNotificationRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmDialog(
        title: "Вы уверены что хотите удалить это уведомление?",
        action: () => _cancel(request),
      )
    );
  }

  Future<bool> _cancel(PendingNotificationRequest request) async {
    await LocalNotificationHelper.instance.cancel(request.id);
    setState(() {
      _notifications.remove(request);
    });
    return true;
  }

  void _openNews(News newsItem) {
    setState(() {
      newsItem.read();
    });
    // TODO: open static page here.
    Map<String, dynamic> data = newsItem.parseData();
    if(data != null && data.containsKey('link')) {
      Navigator.of(context).pushNamed(data['link']);
    }
  }

  Widget get _body => Padding(
    padding: EdgeInsets.only(top: 20),
    child: TabSwitch(
      leftLabel: locale(context).news,
      rightLabel: locale(context).reminders,
      leftTab: NewsList(
        news: _news,
        onOpen: _openNews,
      ),
      rightTab:  NotificationList(
        notifications: _notifications,
        onDelete: _cancelDialog,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomBar,
    );
  }
}
