import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'api_client.dart';
import 'utils/pref_helper.dart';


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

  static Future<List<Channel>> tvChannels() async {
    if(_tvList == null)
      _tvList = await _loadChannels(ChannelType.tv);
    return _tvList;
  }

  static Future<List<Channel>> radioChannels() async {
    if(_radioList == null)
      _radioList = await _loadChannels(ChannelType.radio);
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

  static Future<void> loadTvChannels() async {
    _tvList = await _loadChannels(ChannelType.tv);
  }

  static Future<void> loadRadioChannels() async {
    _radioList = await _loadChannels(ChannelType.radio);
  }

  static Future<void> loadAllChannels() async {
    return Future.wait([
      loadTvChannels(),
      loadRadioChannels(),
    ]);
  }

  static Future<List<Channel>> _loadChannels(ChannelType type) async {
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
    this.locked = (type == ChannelType.tv) ? data['locked'] : false;
    this.logoUrl = data.containsKey('logo') ? data['logo'] : null;
  }

  String get title {
    return '$number. $name';
  }

  Future<List<Program>> get program async {
    if(_type != ChannelType.tv) return null;
    DateTime now = DateTime.now();
    if(_noProgram(now)) {
      await _loadProgram();
      if(_noProgram(now)) {
        await _requestProgram();
        if(_noProgram(now)) return null;
        _saveProgram();
      }
    }
    return _program.where((p) => p.end.isAfter(now)).toList();
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

  bool _noProgram(DateTime by) {
    return _program == null || _program.isEmpty
        || _program.last.end.isBefore(by);
  }

  Future<void> _loadProgram() async {
    FileInfo info = await DefaultCacheManager()
        .getFileFromCache(_programCacheKey);
    if (info != null) {
      String json = info.file.readAsStringSync();
      try {
        List<dynamic> data = jsonDecode(json);
        _program = data.map((item) => Program.fromJson(item)).toList();
      } on FormatException {
        _program = null;
      }
    }
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
    file.writeAsStringSync(jsonEncode(_program));
  }

  String get _programCacheKey => 'program$id';

  Future<bool> get isFavorite async {
    User user = await User.getUser();
    if(user == null) return false;
    return user.hasFavorite(this);
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
