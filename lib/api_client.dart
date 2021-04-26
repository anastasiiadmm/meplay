import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart';


const BASE_URL = 'http://109.71.229.186';
const BASE_API_URL = '$BASE_URL:488';
const BASE_VIDEO_URL = '$BASE_URL:6688';


class ApiException implements Exception {
  String message;

  ApiException([this.message]): super();

  @override
  String toString() {
    return message ?? 'API Error';
  }
}


class ApiClient {
  static Future<T> _wrapRequest<T>(
      Future<http.Response> Function() request,
      [T Function(http.Response) callback]) async {
    try {
      final response = await request();
      print('${response.statusCode} ${response.request.method} ${response.request.url}');
      if (response.statusCode == 200) {
        if (callback == null) return null;
        return callback(response);
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    } on FormatException {
      throw ApiException('Некорректный формат ответа');
    }
  }

  static Future<List<Channel>> getChannels(ChannelType type, [User user]) async {
    String typeString = type == ChannelType.tv ? 'tv' : 'radio';
    String url = '$BASE_API_URL/stalker_portal/meplay/$typeString-channels';
    if(user != null) url += '?msisdn=${user.username}';
    return _wrapRequest<List<Channel>>(
      () => http.get(url),
      (response) {
        List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) {
          if(type == ChannelType.radio) item['locked'] = user == null;
          return Channel.fromJson(item, type: type);
        }).toList();
      }
    );
  }

  static Future<void> requestPassword(String phone) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/pin?msisdn=$phone';
    _wrapRequest<void>(
      () => http.get(url),
      (response) {
        String status = jsonDecode(response.body)['status'];
        if (status != 'ok') {
          throw ApiException('Пользователь не найден');
        }
      }
    );
  }

  static Future<User> auth(String phone, String password) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/auth';
    final body = {
      'username': phone,
      'password': password
    };
    return _wrapRequest<User>(
      () => http.post(url, body: body),
      (response) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['id'] != null) {
          return User(id: responseBody['id'], username: phone, password: password);
        } else if (responseBody['error'] == 'Incorrect password') {
          throw ApiException('Неверный пароль');
        } else if (responseBody['error'] == 'User not found') {
          throw ApiException('Пользователь не найден');
        } else {
          throw ApiException('Неизвестная ошибка');
        }
      }
    );
  }

  static Future<List<Program>> getProgram(int channelId) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/epg?channel_id=$channelId';
    return _wrapRequest<List<Program>>(
      () => http.get(url),
      (response) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Program.fromJson(item)).toList();
      }
    );
  }

  static Future<List<Packet>> getPackets([User user]) async {
    String url = '$BASE_API_URL/stalker_portal/meplay/get_packets';
    if(user != null) {
      url += '?username=${user.username}';
    }
    return _wrapRequest<List<Packet>>(
      () => http.get(url),
      (response) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Packet.fromJson(item)).toList();
      }
    );
  }

  static Future<List<Packet>> addPacket(User user, Packet packet) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/activate_packet';
    final body = {
      'username': user.username,
      'password': user.password,
      'packet_id': packet.id.toString(),
    };
    return _wrapRequest<List<Packet>>(
      () => http.post(url, body: body),
      (response) {
        dynamic responseBody = jsonDecode(response.body);
        if(responseBody is List) {
          List<dynamic> data = responseBody;
          return data.map((item) => Packet.fromJson(item)).toList();
        } else {
          if (responseBody['error'] == 'Incorrect password') {
            throw ApiException('Неверный пароль');
          } else if (responseBody['error'] == 'User not found') {
            throw ApiException('Пользователь не найден');
          } else {
            throw ApiException('Неизвестная ошибка');
          }
        }
      }
    );
  }

  static Future<List<Packet>> removePacket(User user, Packet packet) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/deactivate_packet';
    final body = {
      'username': user.username,
      'password': user.password,
      'packet_id': packet.id.toString(),
    };
    return _wrapRequest<List<Packet>>(
      () =>  http.post(url, body: body),
      (response) {
        dynamic responseBody = jsonDecode(response.body);
        if(responseBody is List) {
          List<dynamic> data = responseBody;
          return data.map((item) => Packet.fromJson(item)).toList();
        } else {
          if (responseBody['error'] == 'Incorrect password') {
            throw ApiException('Неверный пароль');
          } else if (responseBody['error'] == 'User not found') {
            throw ApiException('Пользователь не найден');
          } else {
            throw ApiException('Неизвестная ошибка');
          }
        }
      }
    );
  }

  static Future<void> saveFCMToken(String token) async {
    User user = await User.getUser();
    final url = '$BASE_API_URL/stalker_portal/meplay/fcm_token';
    final body = {
      'token': token,
      if (user != null) 'user_id': '${user.id}',
    };
    return _wrapRequest<void>(
      () =>  http.post(url, body: body),
    );
  }
}
