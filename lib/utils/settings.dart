import 'package:flutter/material.dart';


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

  static const ru = Language('Русский', Locale('ru', 'RU'));
  static const ky = Language('Кыргызча', Locale('ky', 'KG'));
  static const choices = [ky, ru];
  static const defaultChoice = ru;

  static Language getByName(String name) {
    for (Language choice in choices) {
      if(choice.name == name) return choice;
    }
    return defaultChoice;
  }
}
