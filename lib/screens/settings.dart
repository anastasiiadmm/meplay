import 'package:flutter/material.dart';
import '../widgets/bottomNavBar.dart';
import '../utils/pref_helper.dart';
import '../utils/settings.dart';
import '../theme.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  Language _language;
  ListType _listType;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    String langName = await PrefHelper.loadString(PrefKeys.language);
    String listTypeName = await PrefHelper.loadString(PrefKeys.listType);
    setState(() {
      _language = Language.getByName(langName);
      _listType = ListType.getByName(listTypeName);
    });
  }

  Future<void> _savePref(dynamic pref, String key) async {
    await PrefHelper.saveString(key, pref);
  }

  void _setLanguage(Language lang) {
    _savePref(lang, PrefKeys.language);
    setState(() { _language = lang; });
  }

  void _setListType(ListType type) {
    _savePref(type, PrefKeys.listType);
    setState(() { _listType = type; });
  }

  void _openAbout() {

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
    int generalItemsCount = 1;
    int listTypeTitle = generalItemsCount;  // 0 + ...
    int languageTitle = listTypeTitle + ListType.choices.length + 1;
    if(index == 0) {
      return _listTile(
        title: Text('О программе', style: AppFonts.settingsItem),
        padding: EdgeInsets.fromLTRB(15, 11, 15, 11),
        color: AppColors.settingsItem,
        onTap: _openAbout,
      );
    } else if (index == listTypeTitle) {
      return _listTile(
        title: Text('ВИД СПИСКА КАНАЛОВ', style: AppFonts.settingsTitle),
        padding: EdgeInsets.fromLTRB(15, 20, 15, 11),
      );
    } else if (index > listTypeTitle && index < languageTitle) {
      ListType type = ListType.choices[index - listTypeTitle - 1];
      return _listTile(
        title: Text(
          type.name,
          style: type == _listType
              ? AppFonts.settingsSelected
              : AppFonts.settingsItem,
        ),
        padding: EdgeInsets.fromLTRB(15, 11, 15, 11),
        trailing: type == _listType ? AppIcons.check : null,
        onTap: () => _setListType(type),
        color: AppColors.settingsItem,
      );
    } else if (index == languageTitle) {
      return _listTile(
        title: Text('ЯЗЫК', style: AppFonts.settingsTitle),
        padding: EdgeInsets.fromLTRB(15, 20, 15, 11),
      );
    } else {
      Language lang = Language.choices[index - languageTitle - 1];
      return _listTile(
        title: Text(
          lang.name,
          style: lang == _language
              ? AppFonts.settingsSelected
              : AppFonts.settingsItem,
        ),
        padding: EdgeInsets.fromLTRB(15, 11, 15, 11),
        trailing: lang == _language ? AppIcons.check : null,
        onTap: () => _setLanguage(lang),
        color: AppColors.settingsItem,
      );
    }
  }

  Widget get _body {
    return ListView.separated(
      itemBuilder: _settingsTile,
      separatorBuilder: (BuildContext context, int id) => Divider(height: 0,),
      itemCount: Language.choices.length + ListType.choices.length + 3,
    );
  }

  void _back() {
    Navigator.of(context).pop();
  }

  Widget get _appBar {
    return AppBar(
      backgroundColor: AppColors.megaPurple,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: _back,
        icon: AppIcons.back,
      ),
      title: Text('Настройки', style: AppFonts.screenTitle),
      centerTitle: true,
    );
  }

  Widget get _bottomNavBar => BottomNavBar(showIndex: NavItems.profile);

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _appBar,
      body: _body,
      bottomNavigationBar: _bottomNavBar,
    );
  }
}
