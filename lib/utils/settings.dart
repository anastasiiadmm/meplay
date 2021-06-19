import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;


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

  @override
  String toString() => name;
}


class VideoBufferSize {
  final String name;
  final int value;

  const VideoBufferSize(this.name, this.value);

  static const b10s = VideoBufferSize('10 сек', 10);
  static const b20s = VideoBufferSize('20 сек', 20);
  static const b30s = VideoBufferSize('30 сек', 30);
  static const b40s = VideoBufferSize('40 сек', 40);
  static const b50s = VideoBufferSize('50 сек', 50);
  static const choices = [b10s, b20s, b30s, b40s, b50s];
  static const defaultChoice = b20s;

  static VideoBufferSize getByName(String name) {
    for (VideoBufferSize choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultChoice;
  }

  @override
  String toString() => name;
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

  @override
  String toString() => name;
}


// TODO: add some cache with notifications.
// get locale
AppLocalizations locale(BuildContext context) {
  return AppLocalizations.of(context);
}
