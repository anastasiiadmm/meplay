import 'dart:convert';

class Channel {
  int id;
  String name;
  String url;
  int number;
  bool locked;
  String logo;

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
