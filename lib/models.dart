import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:timezone/timezone.dart';

import 'api_client.dart';
import 'utils/pref_helper.dart';
import 'utils/tz_helper.dart';


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
  bool locked;
  String logoUrl;
  List<Program> _program;
  File _logo;
  ChannelType _type;
  static List<Channel> _tvList;
  static List<Channel> _radioList;
  static const maxRecent = 15;

  static ValueNotifier<List<Channel>> _recent = ValueNotifier(null);
  static ValueNotifier<List<Channel>> get recentNotifier => _recent;

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
        print(data);
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

  static Future<void> addRecent(Channel channel) async {
    print('adding');
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

  static Future<List<Channel>> tvChannels() async {
    if(_tvList == null)
      _tvList = await loadChannels(ChannelType.tv);
    return _tvList;
  }

  static Future<List<Channel>> radioChannels() async {
    if(_radioList == null)
      _radioList = await loadChannels(ChannelType.radio);
    return _radioList;
  }

  static Future<Channel> getChannel(int id, ChannelType type) async {
    List<Channel> channels = type == ChannelType.tv
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

  Channel({this.id, this.name, this.url, this.number, this.locked,
    this.logoUrl, ChannelType type: ChannelType.tv}): _type = type;
  
  Channel.fromJson(Map<String, dynamic> data, {
    ChannelType type: ChannelType.tv,
  }): this._type = type {
    this.id = data['id'];
    this.name = data['name'];
    this.url = data['url'];
    this.number = data['number'];
    this.locked = data['locked'];
    this.logoUrl = data.containsKey('logo') ? data['logo'] : null;
  }

  String get title {
    return '$number. $name';
  }

  Future<List<Program>> get program async {
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
    List<Program> fullProgram = await program;
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

  String get startTime {
    return start == null ? '' 
        : '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
  }

  String get endTime {
    return end == null ? ''
        : '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }
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
      ['КАНАЛ', 'КАНАЛА', 'КАНАЛОВ'],
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
  bool read;
  String data;
  static const int maxNews = 20;

  static ValueNotifier<List<News>> _list = ValueNotifier(null);
  static ValueNotifier<List<News>> get listNotifier => _list;

  News({this.id, this.title, this.text,
    this.time, this.read: false, this.data}) {
    if (this.id == null) this.id = this.hashCode;
  }

  static Future<List<News>> get list async {
    if (_list.value == null) await _load();
    return _list.value;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'time': time.toIso8601String(),
      'read': read,
      'data': data,
    };
  }

  News.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.title = data['title'];
    this.text = data['text'];
    this.time = TZHelper.parse(data['time']);
    this.read = data['read'];
    this.data = data['data'];
  }

  static Future<void> add(News item) async {
    List<News> news = await list;
    news.insert(0, item);
    news.sort((n1, n2) => n2.time.compareTo(n1.time));
    if(news.length > maxNews) news.removeLast();
    await _save();
  }

  Future<void> setRead() async {
    read = true;
    await _save();
  }

  static Future<void> _load() async {
    _list.value = await PrefHelper.loadJson(
      PrefKeys.notifications,
      defaultValue: <News>[],
      restore: (data) => (data as List<dynamic>)
          .map<News>((item) => News.fromJson(item))
          .toList(),
    );
  }

  static Future<void> _save() async {
    List<News> news = await list;
    await PrefHelper.saveJson(
      PrefKeys.notifications,
      news,
    );
    _list.value = List<News>.from(news);
  }
}
