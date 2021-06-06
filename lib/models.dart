import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:timezone/timezone.dart';

import 'api_client.dart';
import 'screens/player.dart';
import 'utils/pref_helper.dart';
import 'utils/tz_helper.dart';
import 'utils/settings.dart';


String rPlural(int count, List<String> forms) {
  int lastTwo = count % 100;
  int second = lastTwo ~/ 10;
  if (second == 1) return forms[2]; // 10, 11 - 19 каналов
  int last = lastTwo  % 10;
  if (last == 1) return forms[0]; // 1, 21, 31, ... канал
  if ([2, 3, 4].contains(last)) return forms[1]; // 2 - 4, 22 - 24, ... канала
  return forms[2]; // 5 - 9, 25 - 29, ... каналов
}


enum ChannelType {
  tv,
  radio,
}


class Channel {
  int id;
  String name;
  String url;
  int number;
  int genreId;
  bool locked;
  String logoUrl;
  List<Program> _program;
  File _logo;
  ChannelType _type;
  static List<Channel> _tvList;
  static List<Channel> _radioList;
  static const maxRecent = 15;
  static const radioRegex = r"(.+?) ([0-9]+(\.[0-9]+)? FM)";

  // TODO: DEBUG
  static const useStub = false;

  static ValueNotifier<List<Channel>> _recent = ValueNotifier(null);
  static ValueNotifier<List<Channel>> get recentNotifier => _recent;
  static ValueNotifier<List<Channel>> _popular = ValueNotifier(null);
  static ValueNotifier<List<Channel>> get popularNotifier => _popular;

  static Future<List<Channel>> getRecent() async {
    if (_recent.value == null) await loadRecent();
    return _recent.value;
  }

  static Future<void> loadRecent() async {
    List<Channel> tv = await tvChannels();
    List<Channel> radio = await radioChannels();
    _recent.value = await PrefHelper.loadJson(
      PrefKeys.recent,
      restore: (data) {
        return (data as List<dynamic>).map((item) {
          item = (item as Map<String, dynamic>);
          return (item['type'] == 'tv' ? tv : radio).firstWhere((channel) {
            return channel.id == item['id'];
          });
        }).toList();
      },
      defaultValue: <Channel>[],
    );
  }

  static Future<List<Channel>> getPopular() async {
    if(_popular.value == null) await loadPopular();
    return _popular.value;
  }

  static Future<void> loadPopular() async {
    const List<int> ids = [
      266, 241, 237, 225, 226, 231, 267, 245, 235, 238
    ];
    List<Channel> channels = await tvChannels();
    _popular.value = ids.map((id) {
      return channels.firstWhere((channel) {
        return channel.id == id;
      });
    }).toList();
  }

  static Future<void> addRecent(Channel channel) async {
    if(channel == null) return;
    List<Channel> recent = await getRecent();
    List<Channel> newRecent = [channel];
    for(Channel ch in recent) {
      if(ch == channel) continue;
      newRecent.add(ch);
      if(newRecent.length == maxRecent) break;
    }
    await PrefHelper.saveJson(
      PrefKeys.recent,
      newRecent.map((channel) => {
        'type': channel.type == ChannelType.tv ? 'tv' : 'radio',
        'id': channel.id,
      }).toList(),
    );
    _recent.value = newRecent;
  }

  static List<Channel> get _stubChannels {
    List<Channel> result = [];
    for(int i = 1; i < 11; i++) {
      result.add(Channel(
        id: i,
        name: 'Test $i',
        number: i,
        locked: i % 2 == 0,
        url: 'https://127.0.0.$i',
        genreId: 1 + i % 7,
      ));
    }
    return result;
  }

  static List<Program> _stubProgram(int channelId) {
    DateTime now = DateTime.now();
    List<Program> result = [];
    for(int i = -4; i < 6; i++) {
      DateTime start = now.add(Duration(minutes: 30 * i - 15));
      DateTime end = start.add(Duration(minutes: 30));
      result.add(Program(
        title: 'Test ${(i + 5)}',
        id: (i + 5) * channelId,
        channelId: channelId,
        start: start,
        end: end,
      ));
    }
    return result;
  }

  static Future<List<Channel>> tvChannels({stub: Channel.useStub}) async {
    if(stub) return _stubChannels;
    if(_tvList == null)
      _tvList = await loadChannels(ChannelType.tv);
      _tvList.sort((ch1, ch2) => ch1.number.compareTo(ch2.number));
    return _tvList;
  }

  static Future<List<Channel>> radioChannels({stub: Channel.useStub}) async {
    if(stub) return _stubChannels;
    if(_radioList == null)
      _radioList = await loadChannels(ChannelType.radio);
      _radioList.sort((ch1, ch2) => ch1.number.compareTo(ch2.number));
    return _radioList;
  }

  static Future<Channel> getChannel(int id, ChannelType type, {
    stub: Channel.useStub
  }) async {
    List<Channel> channels = stub
        ? _stubChannels
        : type == ChannelType.tv
        ? await tvChannels()
        : await radioChannels();
    return channels.firstWhere(
      (channel) => channel.id == id,
      orElse: () => null,
    );
  }

  static Future<void> loadTv() async {
    _tvList = await loadChannels(ChannelType.tv);
  }

  static Future<void> loadRadio() async {
    _radioList = await loadChannels(ChannelType.radio);
  }

  static Future<List<Channel>> loadChannels(ChannelType type) async {
    try {
      User user = await User.getUser();
      return await ApiClient.getChannels(type, user);
    } on ApiException catch (e) {
      print(e.message);
      return <Channel>[];
    }
  }

  ChannelType get type => _type;

  String get typeString => _type == ChannelType.tv ? 'tv' : 'radio';

  Channel({this.id, this.name, this.url, this.number,
    this.genreId, this.locked, this.logoUrl,
    ChannelType type: ChannelType.tv}): _type = type;
  
  Channel.fromJson(Map<String, dynamic> data, {
    ChannelType type: ChannelType.tv,
  }): this._type = type {
    this.id = data['id'];
    this.name = data['name'];
    this.url = data['url'];
    this.number = data['number'];
    this.genreId = data.containsKey('genre') ? data['genre']['id'] : null;
    this.locked = data['locked'];
    this.logoUrl = data.containsKey('logo') ? data['logo'] : null;
  }

  String get title {
    return '$number. $name';
  }

  Future<List<Program>> program({stub: Channel.useStub}) async {
    if(stub) return _stubProgram(id);
    if(_type != ChannelType.tv) return null;
    if(_emptyProgram) await _loadProgram();
    if(_emptyProgram) {
      await _requestProgram();
      if(_emptyProgram) return null;
      _saveProgram();
    }
    return _program.where((p) => p.end.isAfter(DateTime.now())).toList();
  }

  Future<Program> get currentProgram async {
    if(_type != ChannelType.tv) return null;
    List<Program> fullProgram = await program();
    if (fullProgram == null) return null;
    return fullProgram.first;
  }

  Future<File> get logo async {
    if (logoUrl == null || logoUrl.isEmpty) {
      return null;
    }
    if(_logo == null) {
      _logo = await DefaultCacheManager().getSingleFile(logoUrl);
    }
    return _logo;
  }

  Future<void> _loadProgram() async {
    FileInfo info = await DefaultCacheManager()
        .getFileFromCache(_programCacheKey);
    if (info != null) {
      String json = info.file.readAsStringSync();
      try {
        dynamic data = jsonDecode(json);
        if(data is List) await _clearProgram();
        else {
          data = data as Map<String, dynamic>;
          List<dynamic> programData = data['program'];
          DateTime cacheTime = DateTime.parse(data['datetime']);
          if(_oldProgramCache(cacheTime)) await _clearProgram();
          else _program = programData
              .map((item) => Program.fromJson(item))
              .toList();
          if(_oldProgram) await _clearProgram();
        }
      } on FormatException {
        await _clearProgram();
      }
    }
  }

  Future<void> _clearProgram() async {
    await DefaultCacheManager().removeFile(_programCacheKey);
    _program = null;
  }

  bool get _emptyProgram => _program == null || _program.isEmpty;

  bool get _oldProgram => _program.last.end.isBefore(DateTime.now());

  bool _oldProgramCache(DateTime cacheTime) {
    DateTime now = DateTime.now();
    DateTime morning = DateTime(now.year, now.month, now.day, 6, 0, 0);
    return cacheTime.isBefore(morning) && now.isAfter(morning);
  }

  Future<void> _requestProgram() async {
    try {
      _program = await ApiClient.getProgram(id);
    } on ApiException {
      _program = null;
    }
  }

  Future<void> _saveProgram() async {
    File file = await DefaultCacheManager().putFile(
        _programCacheKey,
        Uint8List(0),
        fileExtension: 'json',
    );
    file.writeAsStringSync(jsonEncode(<String, dynamic>{
      'program': _program,
      'datetime': DateTime.now().toIso8601String(),
    }));
  }

  String get _programCacheKey => 'program$id';

  Future<bool> get isFavorite async {
    User user = await User.getUser();
    if(user == null) return false;
    return user.hasFavorite(this);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is Channel && this.type == other.type && this.id == other.id;
  }

  @override
  int get hashCode => hashValues(id, type);

  Future<void> open(BuildContext context, {List<Channel> channels}) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PlayerScreen(
          channelId: id,
          channelType: type,
          channels: channels
              ?? (this.type == ChannelType.tv ? _tvList : _radioList),
        ),
        settings: RouteSettings(name: '/$typeString/$id'),
      ),
    );
  }

  Channel next(List<Channel> fromList) {
    int index = fromList.indexOf(this);
    if(index < fromList.length - 1) return fromList[index + 1];
    return fromList[0];
  }

  Channel prev(List<Channel> fromList) {
    int index = fromList.indexOf(this);
    if(index > 0) return fromList[index - 1];
    return fromList[fromList.length - 1];
  }

  Genre get category {
    return Genre.genres.firstWhere((genre) => genreId == genre.id);
  }

  String get radioName {
    RegExpMatch result = RegExp(radioRegex).firstMatch(name);
    return result == null ? name : result.group(1);
  }

  String get radioFM {
    RegExpMatch result = RegExp(radioRegex).firstMatch(name);
    return result == null ? '' : result.group(2);
  }
}


class AppBanner {
  String imageUrl;
  String targetUrl;
  File _image;

  AppBanner({this.imageUrl, this.targetUrl});

  Future<File> get image async {
    if (imageUrl == null) return null;
    if(_image == null) {
      _image = await DefaultCacheManager().getSingleFile(imageUrl);
    }
    return _image;
  }
}


class Program {
  String title;
  int duration;
  DateTime start;
  DateTime end;
  int id;
  int channelId;

  Program({this.title, this.start, this.end,
    this.duration, this.id, this.channelId});

  Program.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.duration = data['duration'];
    this.title = data['title'];
    this.start = DateTime.tryParse(data['start']);
    this.end = DateTime.tryParse(data['end']);
    this.channelId = data['channel_id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration,
      'title': title,
      'start': start?.toIso8601String(),
      'end': end?.toIso8601String(),
      'channel_id': channelId,
    };
  }

  String get timeTitle {
    String result = startTime;
    if(result != '') result += ' ';
    return result + title;
  }

  String get startDate => start == null ? ''
      : '${start.day.toString().padLeft(2, '0')}.${start.month.toString().padLeft(2, '0')}.${start.year}';

  String get startTime => start == null ? '' 
      : '${start.hour}:${start.minute.toString().padLeft(2, '0')}';

  String get startDateTime => '$startDate $startTime'.trim();

  String get endDate => end == null ? ''
      : '${end.day.toString().padLeft(2, '0')}.${end.month.toString().padLeft(2, '0')}.${end.year}';

  String get endTime => end == null ? ''
      : '${end.hour}:${end.minute.toString().padLeft(2, '0')}';

  String get endDateTime => '$endDate $endTime'.trim();
}


class User {
  String username;
  String password;
  String token;
  String refreshToken;
  int id;
  List<Packet> _packets;
  List<int> _tvFavorites;
  List<int> _radioFavorites;
  static ValueNotifier<User> _user = ValueNotifier<User>(null);

  User({this.username, this.password, this.token, this.refreshToken, this.id});

  static ValueNotifier<User> get userNotifier => _user;

  static Future<User> getUser() async {
    if (_user.value == null) await loadUser();
    return _user.value;
  }

  static Future<bool> hasUser() async {
    return await getUser() != null;
  }

  static Future<void> loadUser() async {
    _user.value = await PrefHelper.loadJson(
      PrefKeys.user,
      restore: (data) => User.fromJson(data),
    );
  }

  static Future<void> setUser(User user) async {
    _user.value = user;
    await PrefHelper.saveJson(
      PrefKeys.user,
      user,
    );
  }

  static Future<void> clearUser() async {
    _user.value = null;
    await PrefHelper.clear(PrefKeys.user);
  }

  User.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.username = data.containsKey('username') ? data['username'] : null;
    this.password = data.containsKey('password') ? data['password'] : null;
    this.token = data.containsKey('token') ? data['token'] : null;
    this.refreshToken = data.containsKey('refreshToken') ? data['refreshToken'] : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'token': token,
      'refreshToken': refreshToken,
    };
  }

  Future<List<Packet>> getPackets() async {
    if(_packets == null)
      await _loadPackets();
    return _packets;
  }

  Future<void> _loadPackets() async {
    try {
      _packets = await ApiClient.getPackets(this);
    } on ApiException {
      _packets = null;
    }
  }

  Future<List<Packet>> addPacket(Packet packet) async {
    try {
      _packets = await ApiClient.addPacket(this, packet);
      return _packets;
    } on ApiException {
      return null;
    }
  }

  Future<List<Packet>> removePacket(Packet packet) async {
    try {
      _packets = await ApiClient.removePacket(this, packet);
      return _packets;
    } on ApiException {
      return null;
    }
  }

  Future<List<int>> _getFavorites(ChannelType type) async {
    return type == ChannelType.tv
        ? await tvFavorites()
        : await radioFavorites();
  }

  Future<List<int>> tvFavorites() async {
    if (_tvFavorites == null)
      _tvFavorites = await _loadFavorites(ChannelType.tv);
    return _tvFavorites;
  }

  Future<List<int>> radioFavorites() async {
    if (_radioFavorites == null)
      _radioFavorites = await _loadFavorites(ChannelType.radio);
    return _radioFavorites;
  }

  Future<void> addFavorite(Channel channel) async {
    List<int> favorites = await _getFavorites(channel.type);
    if (!favorites.contains(channel.id)) favorites.add(channel.id);
    await _saveFavorites(channel.type);
  }

  Future<void> removeFavorite(Channel channel) async {
    List<int> favorites = await _getFavorites(channel.type);
    if(favorites.contains(channel.id)) favorites.remove(channel.id);
    await _saveFavorites(channel.type);
  }

  Future<bool> hasFavorite(Channel channel) async {
    List<int> favorites = await _getFavorites(channel.type);
    return favorites.contains(channel.id);
  }

  Future<List<int>> _loadFavorites(ChannelType type) async {
    String prefKey = type == ChannelType.tv
        ? PrefKeys.tvFavorites(id)
        : PrefKeys.radioFavorites(id);
    return await PrefHelper.loadJson(
      prefKey,
      defaultValue: <int>[],
      restore: (data) => data.cast<int>(),
    );
  }
  
  Future<void> _saveFavorites(ChannelType type) async {
    if(type == ChannelType.tv) await PrefHelper.saveJson(
      PrefKeys.tvFavorites(id),
      _tvFavorites,
    );
    else await PrefHelper.saveJson(
      PrefKeys.radioFavorites(id),
      _radioFavorites,
    );
  }
}


class Packet {
  String name;
  int channelCount;
  String priceLabel;
  bool isActive;
  int id;

  Packet({this.id, this.name, this.channelCount,
    this.priceLabel, this.isActive});

  String get channelDisplay {
    return '$channelCount ' + rPlural(
      channelCount,
      ['канал', 'канала', 'каналов'],
    );
  }

  Packet.fromJson(Map<String, dynamic> data) {
    this.id = data.containsKey('packet_id') ? data['packet_id'] : data['id'];
    this.channelCount = data.containsKey('num_channels') ? data['num_channels'] : data['channelCount'];
    this.name = data['name'];
    this.priceLabel = data.containsKey('amount') ? data['amount'] : data['priceLabel'];
    this.isActive = data.containsKey('connected') ? data['connected'] : data['isActive'];
  }
}

class News {
  int id;
  String title;
  String text;
  TZDateTime time;
  bool isRead;
  String data;
  static const int maxNews = 99;

  static List<News> _list;
  static ValueNotifier<int> _unreadCount = ValueNotifier(0);
  static ValueNotifier<int> get unreadCountNotifier => _unreadCount;

  News({this.id, this.title, this.text,
    this.time, this.isRead: false, this.data}) {
    if (this.id == null) this.id = this.hashCode;
  }

  static Future<List<News>> get list async {
    if (_list == null) await load();
    return _list;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'time': time.toIso8601String(),
      'read': isRead,
      'data': data,
    };
  }

  News.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.title = data['title'];
    this.text = data['text'];
    this.time = TZHelper.parse(data['time']);
    this.isRead = data['read'];
    this.data = data['data'];
  }

  static Future<void> add(News item) async {
    _list.insert(0, item);
    if(_list.length > maxNews) {
      News last = _list.removeLast();
      if(last.isRead) _unreadCount.value += 1;
    } else {
      _unreadCount.value += 1;
    }
    await _save();
  }

  void read() {
    isRead = true;
    _unreadCount.value -= 1;
    _save();
  }

  static Future<void> load() async {
    _list = await PrefHelper.loadJson(
      PrefKeys.news,
      defaultValue: <News>[],
      restore: (data) => (data as List<dynamic>)
          .map<News>((item) => News.fromJson(item))
          .toList(),
    );
    _unreadCount.value = _list.where((item) => !item.isRead).length;
  }

  static Future<void> _save() async {
    await PrefHelper.saveJson(
      PrefKeys.news,
      _list,
    );
  }
}


class Genre {
  int id;
  String name;
  bool censored;

  Genre({this.id, this.name, this.censored: false});

  static List<Genre> genres = [
    Genre(id: 0, name: 'Все'),
    Genre(id: 3, name: 'Детские'),
    Genre(id: 5, name: 'Документальные'),
    Genre(id: 4, name: 'Кино'),
    Genre(id: 7, name: 'Музыка'),
    Genre(id: 1, name: 'Новости'),
    Genre(id: 2, name: 'Развлекательные'),
    Genre(id: 6, name: 'Спортивные'),
  ];

  String localName(BuildContext context) {
    final l = locale(context);
    switch (id) {
      case 0: return l.categoryAll;
      case 1: return l.categoryNews;
      case 2: return l.categoryEntertainment;
      case 3: return l.categoryChild;
      case 4: return l.categoryMovie;
      case 5: return l.categoryDoc;
      case 6: return l.categorySport;
      case 7: return l.categoryMusic;
      default: return name;
    }
  }
}
