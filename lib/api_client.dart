import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
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
  static Future<List<Channel>> getChannels([User user]) async {
    String url = '$BASE_API_URL/stalker_portal/meplay/tv-channels';
    if(user != null) {
      url += '?msisdn=${user.username}';
    }
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => Channel.fromJson(item)).toList();
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    }
  }

  static Future<void> requestPassword(String phone) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/pin?msisdn=$phone';
    try {
      final response = await http.get(url);
      if(response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status != 'ok') {
          throw ApiException('Пользователь не найден');
        }
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    }
  }

  static Future<User> auth(String phone, String password) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/auth';
    final body = {
      'username': phone,
      'password': password
    };
    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
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
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    }
  }

  static Future<List<Program>> getProgram(int channelId) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/epg?channel_id=$channelId';
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Program.fromJson(item)).toList();
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    }
  }

  static Future<List<Packet>> getPackets([User user]) async {
    String url = '$BASE_API_URL/stalker_portal/meplay/get_packets';
    if(user != null) {
      url += '?username=${user.username}';
    }
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Packet.fromJson(item)).toList();
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    }
  }

  static Future<List<Packet>> addPacket(User user, Packet packet) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/activate_packet';
    final body = {
      'username': user.username,
      'password': user.password,
      'packet_id': packet.id.toString(),
    };
    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
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
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    }
  }

  static Future<List<Packet>> removePacket(User user, Packet packet) async {
    final url = '$BASE_API_URL/stalker_portal/meplay/deactivate_packet';
    final body = {
      'username': user.username,
      'password': user.password,
      'packet_id': packet.id.toString(),
    };
    print(body);
    try {
      final response = await http.post(url, body: body);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
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
      } else {
        throw ApiException('Ошибка при выполнении запроса');
      }
    } on SocketException {
      throw ApiException('Нет подключения к интернету');
    }
  }

  static Future<User> authOld(String username, String password) async {
    final url = '$BASE_API_URL/stalker_portal/auth/token';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    var deviceData = await _getDeviceData();
    var signature = _getSignature(deviceData['id']);
    final body = {
      'grant_type': 'password',
      'username': username,
      'password': password,
      'client_type': 'Robot',
      'model': deviceData['model'],
      'hw_version': _getHWId(deviceData['model'], signature, timestamp ~/ 1000),
      'signature': signature,
      'timestamp': (timestamp).toString(),
    };
    print(body);
    final response = await http.post(url, body: body);
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      return null;
    }
  }

  static String _getSignature(deviceId) {
    var data = utf8.encode('$deviceId');
    var hash = sha1.convert(data).toString();
    return hash;
  }

  static String _getHWId(String model, String signature, int timestamp) {
    var key = utf8.encode(signature);

    var hmacSha1 = new Hmac(sha1, key);
    var hmacMd5 = new Hmac(md5, key);

    var sha1Data = utf8.encode(model);
    var sha1Hash = hmacSha1.convert(sha1Data).toString();

    var md5Data = utf8.encode(model);
    var md5Hash = hmacMd5.convert(md5Data).toString();

    var hash = '$sha1Hash.$md5Hash.$timestamp';
    return hash;
  }

  static Future<Map<String, String>> _getDeviceData() async {
    final deviceData = <String, String>{};

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData['model'] = androidInfo.model;
        deviceData['id'] = androidInfo.androidId;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        deviceData['model'] = iosDeviceInfo.model;
        deviceData['id'] = iosDeviceInfo.identifierForVendor;
      }
    } on PlatformException {
      deviceData['Error'] = 'Failed to get platform version.';
      deviceData['model'] = null;
      deviceData['id'] = null;
    }

    return deviceData;
  }
}
