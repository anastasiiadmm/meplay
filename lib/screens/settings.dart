import 'package:flutter/material.dart';
import '../widgets/app_toolbar.dart';
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

  void _setLanguage(AppLocale lang) {
    _savePref(lang, PrefKeys.language);
    setState(() { _locale = lang; });
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
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmDialog(
        // TODO: translate
        title: "Выход",
        text: 'Вы уверены, что хотите выйти?',
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

  Widget _listTile({
    void Function() onTap,
    Widget leading,
    Widget title,
    Widget subtitle,
    Widget trailing,
    EdgeInsets padding: EdgeInsets.zero,
    Color color: AppColors.transparent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        color: color,
        child: Row(
          children: [
            if(leading != null) leading,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(title != null) title,
                  if(subtitle != null) subtitle,
                ],
              ),
            ),
            if(trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(BuildContext context, int index) {
    int generalItemsCount = 0; // TODO: 1
    int languageTitle = generalItemsCount;  // 0 + ...
    int listTypeTitle = languageTitle + AppLocale.choices.length + 1;
    int exitTile = listTypeTitle + ChannelListType.choices.length + 1;
    AppLocalizations l = locale(context);
    // TODO:
    // if(index == 0) {
    //   return _listTile(
    //     title: Text('О программе', style: AppFonts.settingsItem),
    //     padding: EdgeInsets.fromLTRB(15, 11, 15, 11),
    //     color: AppColors.settingsItem,
    //     onTap: _openAbout,
    //   );
    // } else
    if (index == languageTitle) {
      return _listTile(
        title: Text(l.settingsLanguage, style: AppFontsV2.settingsTitle),
        padding: EdgeInsets.fromLTRB(16, 13, 16, 3),
      );
    } else if (index > languageTitle && index < listTypeTitle) {
      AppLocale lang = AppLocale.choices[index - languageTitle - 1];
      return _listTile(
        title: Text(
          lang.name,
          style: AppFontsV2.textPrimary,
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        trailing: lang == _locale ? AppIconsV2.check : null,
        onTap: () => _setLanguage(lang),
        color: AppColorsV2.blockBg,
      );
    } else if (index == listTypeTitle) {
      return _listTile(
        title: Text(l.channelListView, style: AppFontsV2.settingsTitle),
        padding: EdgeInsets.fromLTRB(16, 13, 16, 3),
      );
    } else if (index == exitTile) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 30, 16, 16),
        child: _logoutButton,
      );
    } else {
      ChannelListType type = ChannelListType.choices[index - listTypeTitle - 1];
      return _listTile(
        title: Text(
          type.name,
          style: AppFontsV2.textPrimary,
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        trailing: type == _listType ? AppIconsV2.check : null,
        onTap: () => _setListType(type),
        color: AppColorsV2.blockBg,
      );
    }
  }

  Widget get _body {
    return ListView.separated(
      itemBuilder: _settingsTile,
      separatorBuilder: (BuildContext context, int id) => SizedBox(height: 1,),
      itemCount: AppLocale.choices.length + ChannelListType.choices.length + 3,
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
