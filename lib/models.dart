import 'dart:async';
import 'dart:convert';
import 'api_client.dart';


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

  Future<List<Program>> get program async {
    // TODO: add persistent store.
    if(_programEnded) await _loadProgram();
    if (_program == null) return _program;
    DateTime now = DateTime.now();
    return _program.where((p) => p.end.isAfter(now)).toList();
  }

  bool get _programEnded {
    return _program == null || _program.isEmpty
        || _program.last.end.isBefore(DateTime.now());
  }

  Future<void> _loadProgram() async {
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
    this.start = DateTime.tryParse(data['start']);
    this.end = DateTime.tryParse(data['end']);
    this.channelId = data['channel_id'];
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
