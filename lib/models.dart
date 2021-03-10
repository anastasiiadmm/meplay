import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:timezone/timezone.dart';

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
    if (_user == null)
      _user = await PrefHelper.loadJson(
        PrefKeys.user,
        restore: (data) => User.fromJson(data),
      );
    return _user;
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
    // TODO: add persistence.
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

  Future<List<Channel>> filterFavorites(List<Channel> channels) async {
    List<int> favorites = await getFavorites();
    return channels.where((channel) => favorites.contains(channel.id))
        .toList();
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


class Notification {
  int id;
  String title;
  String text;
  TZDateTime time;
  bool remote;
  bool active;
  String data;

  static List<Notification> _list;

  Notification({this.id, this.title, this.text,
    this.time, this.remote: false, this.active: true, this.data}) {
    if (this.id == null) this.id = this.hashCode;
  }

  static Future<List<Notification>> get list async {
    if (_list == null) await _load();
    return _list;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'time': time.toIso8601String(),
      'remote': remote,
      'active': active,
      'data': data,
    };
  }
  
  Notification.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.title = data['title'];
    this.text = data['text'];
    // TODO: get Location and parse in local datetime
    // this.time = TZDateTime.parse(... , data['time']);
    this.remote = data['remote'];
    this.active = data['active'];
    this.data = data['data'];
  }

  static Future<void> add(Notification item) async {
    List<Notification> items = await list;
    items.add(item);
    items.sort((n1, n2) => n2.time.compareTo(n1.time));
    if(items.length > 50) items.removeLast();
    await _save();
  }

  static Future<void> remove(Notification item) async {
    (await list).remove(item);
    await _save();
  }

  static Future<Notification> find(int id) async {
    return (await list)
        .firstWhere((item) => item.id == id, orElse: () => null);
  }

  Future<void> activate() async {
    active = true;
    await _save();
  }

  Future<void> deactivate() async {
    active = false;
    await _save();
  }

  static Future<void> _load() async {
    _list = await PrefHelper.loadJson(
      PrefKeys.notifications,
      defaultValue: <Notification>[],
      restore: (data) => (data as List<dynamic>).map<Notification>(
              (item) => Notification.fromJson(item)
      ).toList(),
    );
  }

  static Future<void> _save() async {
    await PrefHelper.saveJson(
      PrefKeys.notifications,
      _list ?? <Notification>[],
    );
  }
}
