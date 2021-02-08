import 'dart:async';
import 'dart:convert';
import 'api_client.dart';


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
  String logo;
  List<Program> _program;

  Channel({this.id, this.name, this.url, this.number, this.locked, this.logo});
  
  Channel.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.name = data['name'];
    this.url = data['url'];
    this.number = data['number'];
    this.locked = data['locked'];
    this.logo = data['logo'];
  }

  String get title {
    return '$number. $name';
  }

  Future<List<Program>> getProgram() async {
    // TODO: add persistent store.
    if(_noProgram) await _getProgram();
    if (_program == null) return _program;
    DateTime now = DateTime.now();
    return _program.where((p) => p.end.isAfter(now)).toList();
  }

  bool get _noProgram {
    return _program == null || _program.isEmpty
        || _program.last.end.isBefore(DateTime.now());
  }

  Future<void> _getProgram() async {
    try {
      _program = await ApiClient.getProgram(id);
    } on ApiException {
      _program = null;
    }
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
    this.start = DateTime.parse(data['start']);
    this.end = DateTime.parse(data['end']);
    this.channelId = data['channel_id'];
  }

  String toJson() {
    return jsonEncode({
      'id': id,
      'duration': duration,
      'title': title,
      'start': start?.toIso8601String(),
      'end': end?.toIso8601String(),
      'channelId': channelId,
    });
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

  User({this.username, this.password, this.token, this.refreshToken, this.id});

  User.fromJson(Map<String, dynamic> data) {
    this.id = data['id'];
    this.username = data.containsKey('username') ? data['username'] : null;
    this.password = data.containsKey('password') ? data['password'] : null;
    this.token = data.containsKey('token') ? data['token'] : null;
    this.refreshToken = data.containsKey('refreshToken') ? data['refreshToken'] : null;
  }

  String toJson() {
    Map<String, dynamic> data = {
      'id': id,
      'username': username,
      'password': password,
      'token': token,
      'refreshToken': refreshToken,
    };
    return jsonEncode(data);
  }
}


class Package {
  String name;
  int channels;
  String price;
  bool isActive;
  int id;

  Package({this.id, this.name, this.channels, this.price, this.isActive,});

  String get channelDisplay {
    return rPlural(channels, ['КАНАЛ', 'КАНАЛА', 'КАНАЛОВ']);
  }
}
