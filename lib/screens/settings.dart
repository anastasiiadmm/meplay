import 'package:flutter/material.dart';
import '../widgets/app_toolbar.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/modals.dart';
import '../utils/pref_helper.dart';
import '../utils/settings.dart';
import '../theme.dart';
import '../models.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  AppLocale _locale;
  ChannelListType _listType;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    String langName = await PrefHelper.loadString(PrefKeys.language);
    String listTypeName = await PrefHelper.loadString(PrefKeys.listType);
    setState(() {
      _locale = AppLocale.getByName(langName);
      _listType = ChannelListType.getByName(listTypeName);
    });
  }

  Future<void> _savePref(dynamic pref, String key) async {
    await PrefHelper.saveString(key, pref);
  }

  void _setLocale(AppLocale locale) {
    _savePref(locale, PrefKeys.language);
    setState(() { _locale = locale; });
  }

  void _setListType(ChannelListType type) {
    _savePref(type, PrefKeys.listType);
    setState(() { _listType = type; });
  }

  // TODO:
  // void _openAbout() {
  // }

  Future<bool> _logout() async {
    await User.clearUser();
    await Future.wait([
      Channel.loadTv(),
      Channel.loadRadio(),
    ]);
    await Future.wait([
      Channel.loadRecent(),
      Channel.loadPopular(),
    ]);
    Navigator.of(context).popUntil((route) => route.isFirst);
    return true;
  }

  void _logoutDialog() {
    AppLocalizations l = locale(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmDialog(
        title: l.exit,
        text: l.exitConfirm,
        action: _logout,
        autoPop: false,
      ),
    );
  }

  Widget get _logoutButton {
    return InkWell(
      onTap: _logoutDialog,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsV2.item,
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Text(
          locale(context).settingsLogout,
          style: AppFontsV2.smallButton,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget get _body {
    AppLocalizations l = locale(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TODO: 
          // Padding(
          //   padding: EdgeInsets.only(top: 20),
          //   child: SettingsTile(
          //     text: l.settingsAbout,
          //     onTap: _openAbout,
          //   )
          // ),
          SettingsBlock<AppLocale>(
            title: l.settingsLanguage, 
            items: AppLocale.choices,
            getText: (item) => item.name,
            onTap: _setLocale,
            isActive: (item) => item == _locale,
          ),
          SettingsBlock<ChannelListType>(
            title: l.channelListType,
            items: ChannelListType.choices,
            getText: (item) => item.name,
            onTap: _setListType,
            isActive: (item) => item == _listType,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
            child: _logoutButton,
          ),
        ],
      ),
    );
  }

  Widget get _appBar {
    return AppToolBar(
      title: locale(context).settingsTitle,
    );
  }

  Widget get _bottomNavBar => BottomNavBar(showIndex: NavItems.profile);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsV2.darkBg,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
