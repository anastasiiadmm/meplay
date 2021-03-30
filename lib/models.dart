import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
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


class Channel {
  int id;
  String name;
  String url;
  int number;
  bool locked;
  String logoUrl;
  List<Program> _program;
  File _logo;
  static List<Channel> _list;

  static Future<List<Channel>> getChannels() async {
    if(_list == null) await loadChannels();
    return _list;
  }

  static Future<void> loadChannels() async {
    try {
      User user = await User.getUser();
      _list = await ApiClient.getChannels(user);
    } on ApiException catch (e) {
      print(e.message);
      _list = <Channel>[];
    }
  }

  Channel({this.id, this.name, this.url, this.number, this.locked,
    this.logoUrl});
  
  Channel.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.name = data['name'];
    this.url = data['url'];
    this.number = data['number'];
    this.locked = data['locked'];
    this.logoUrl = data['logo'];
  }

  String get title {
    return '$number. $name';
  }

  Future<List<Program>> get program async {
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
    if (user == null) return false;
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
  List<int> _favorites;
  static User _user;

  User({this.username, this.password, this.token, this.refreshToken, this.id});

  static Future<User> getUser() async {
    if (_user == null) await loadUser();
    return _user;
  }

  static Future<bool> hasUser() async {
    return await getUser() == null;
  }

  static Future<void> loadUser() async {
    _user = await PrefHelper.loadJson(
      PrefKeys.user,
      restore: (data) => User.fromJson(data),
    );
  }

  static Future<void> setUser(User user) async {
    _user = user;
    await PrefHelper.saveJson(
      PrefKeys.user,
      user,
    );
  }

  static Future<void> clearUser() async {
    _user = null;
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

  Future<List<int>> getFavorites() async {
    if (_favorites == null)
      await _loadFavorites();
    return _favorites;
  }

  Future<void> addFavorite(Channel channel) async {
    List<int> favorites = await getFavorites();
    if (!favorites.contains(channel.id)) favorites.add(channel.id);
    await _saveFavorites();
  }

  Future<void> removeFavorite(Channel channel) async {
    List<int> favorites = await getFavorites();
    if(favorites.contains(channel.id)) favorites.remove(channel.id);
    await _saveFavorites();
  }

  Future<bool> hasFavorite(Channel channel) async {
    List<int> favorites = await getFavorites();
    return favorites.contains(channel.id);
  }

  Future<void> _loadFavorites() async {
    _favorites = await PrefHelper.loadJson(
      PrefKeys.favorites(id),
      defaultValue: <int>[],
      restore: (data) => data.cast<int>(),
    );
  }
  
  Future<void> _saveFavorites() async {
    await PrefHelper.saveJson(
      PrefKeys.favorites(id),
      _favorites,
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
