import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ChannelListType {
  final String name;
  final String value;

  const ChannelListType(this.name, this.value);
  
  static const list = ChannelListType('Список', 'list');
  static const grid = ChannelListType('Плитка', 'grid');
  static const choices = [list, grid];
  static const defaultChoice = list;

  static ChannelListType getByName(String name) {
    for (ChannelListType choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultChoice;
  }
}


class AppLocale {
  final String name;
  final Locale value;

  const AppLocale(this.name, this.value);

  // copy from AppLocalizations.supportedLocales and give names.
  static const ru = AppLocale('Русский', Locale('ru', 'RU'));
  static const ky = AppLocale('Кыргызча', Locale('ky', 'KG'));
  static const choices = [ky, ru];  // defines ordering.
  static const defaultChoice = ru;

  static AppLocale getByName(String name) {
    for (AppLocale choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultChoice;
  }
}


// TODO: add some cache with notifications.
// get locale
AppLocalizations locale(BuildContext context) {
  return AppLocalizations.of(context);
}
