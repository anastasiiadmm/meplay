import 'package:flutter/material.dart';
import '../widgets/bottomNavBar.dart';
import '../utils/pref_helper.dart';
import '../theme.dart';


class ListType {
  final String name;
  final String value;

  const ListType(this.name, this.value);

  static const hexes = ListType('Шестиугольники', 'hexes');
  static const list = ListType('Список', 'list');
  static const blocks = ListType('Плитка', 'tiles');
  static const choices = [hexes, list, blocks];
  static const defaultChoice = hexes;

  static ListType getByName(String name) {
    for (ListType choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultChoice;
  }
}


class Language {
  final String name;
  final Locale value;

  const Language(this.name, this.value);

  static const ru = Language('Русский', Locale('ru', 'ru'));
  static const ky = Language('Кыргызча', Locale('ky', 'kg'));
  static const choices = [ky, ru];
  static const defaultChoice = ru;

  static Language getByName(String name) {
    for (Language choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultChoice;
  }
}


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
    String name = await PrefHelper.loadString(PrefKeys.language);
    _language = Language.getByName(name);
    name = await PrefHelper.loadString(PrefKeys.listType);
    _listType = ListType.getByName(name);
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

  Widget _settingsTile(BuildContext context, int index) {
    int generalItemsCount = 1;
    int listTypeTitle = generalItemsCount;  // 0 + ...
    int languageTitle = listTypeTitle + ListType.choices.length + 1;
    if(index == 0) {
      return ListTile(
        title: Text('О программе', style: AppFonts.settingsItem),
        contentPadding: EdgeInsets.fromLTRB(15, 11, 15, 11),
        onTap: _openAbout,
      );
    } else if (index == listTypeTitle) {
      return ListTile(
        title: Text('ВИД СПИСКА КАНАЛОВ', style: AppFonts.settingsTitle),
        contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 11),
      );
    } else if (index > listTypeTitle && index < languageTitle) {
      ListType type = ListType.choices[index - listTypeTitle - 1];
      return ListTile(
        title: Text(
          type.name,
          style: type == _listType
              ? AppFonts.settingsSelected
              : AppFonts.settingsItem,
        ),
        contentPadding: EdgeInsets.fromLTRB(15, 11, 15, 11),
        trailing: type == _listType ? AppIcons.check : null,
        onTap: () => _setListType(type),
      );
    } else if (index == languageTitle) {
      return ListTile(
        title: Text('ЯЗЫК', style: AppFonts.settingsTitle),
        contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 11),
      );
    } else {
      Language lang = Language.choices[index - languageTitle - 1];
      return ListTile(
        title: Text(
          lang.name,
          style: lang == _language
              ? AppFonts.settingsSelected
              : AppFonts.settingsItem,
        ),
        contentPadding: EdgeInsets.fromLTRB(15, 11, 15, 11),
        trailing: lang == _language ? AppIcons.check : null,
        onTap: () => _setLanguage(lang),
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
