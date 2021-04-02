import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class M3UHeaders {
  static const format = '#EXTM3U';
  static const version = '#EXT-X-VERSION';
  static const targetDuration = '#EXT-X-TARGETDURATION';
  static const mediaSequence = '#EXT-X-MEDIA-SEQUENCE';
  static const playlistType = '#EXT-X-PLAYLIST-TYPE';
  static const playlistTypeEvent = 'EVENT';
  static const playlistTypeVOD = 'VOD';
  static const extInf = '#EXTINF';
}


class M3UPlaylist {
  final String url;
  List<M3UChunk> chunks;
  Map<String, String> headers;
  File _file;
  int _mediaSequence;
  int _version;
  double _targetDuration;
  int _lastChunkId = -1;
  double _bufferedDuration = 0;
  double _totalDuration = 0;

  static const awaitModeAll = 'awaitAll';
  static const awaitModeOneByOne = 'awaitOneByOne';
  static const awaitModeNone = 'awaitNone';

  Duration get bufferedDuration {
    return Duration(microseconds:(_bufferedDuration * 1000000).floor());
  }

  Duration get totalDuration {
    return Duration(microseconds:(_totalDuration * 1000000).floor());
  }

  M3UPlaylist(this.url) {
    chunks = <M3UChunk>[];
    headers = <String, String>{};
  }

  String getHeader(String key, {String defaultValue}) {
    if (headers.containsKey(key)) {
      return headers[key];
    }
    return defaultValue;
  }

  void setHeader(String key, dynamic value) {
    headers[key] = value.toString();
  }

  int get mediaSequence {
    _mediaSequence ??= int.tryParse(getHeader(M3UHeaders.mediaSequence));
    return _mediaSequence;
  }

  set mediaSequence(int value) {
    setHeader(M3UHeaders.mediaSequence, value);
    _mediaSequence = value;
  }

  double get targetDuration {
    _targetDuration ??= double.tryParse(getHeader(M3UHeaders.targetDuration));
    return _targetDuration;
  }

  set targetDuration(double value) {
    setHeader(M3UHeaders.targetDuration, value);
    _targetDuration = value;
  }

  int get version {
    _version ??= int.tryParse(getHeader(M3UHeaders.version));
    return _version;
  }

  set version(int value) {
    _version = value;
    setHeader(M3UHeaders.version, value);
  }

  File get file => _file;
  String get path => _file?.path;

  Future<void> load() async {
    print('Loading: $url');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      parse(response.body);
      await save();
    }
  }

  Future<void> loadChunks({String awaitMode: awaitModeNone}) async {
    final chunksToLoad = chunks.where((e) => e.file == null);
    switch (awaitMode) {
      case awaitModeNone:
        var futures = chunksToLoad.map(
          (e) => e.load().then((d) => _bufferedDuration += d)
        );
        Future.wait(futures).then((_) => save());
        break;
      case awaitModeOneByOne:
        await Future.forEach(
          chunksToLoad,
          (e) async => await e.load().then((d) => _bufferedDuration += d)
        ).then((_) => save());
        break;
      case awaitModeAll:
        var futures = chunksToLoad.map(
          (e) => e.load().then((d) => _bufferedDuration += d)
        );
        await Future.wait(futures).then((_) => save());
        break;
      default:
        throw Exception('Unsupported mode');
    }
  }

  void merge(M3UPlaylist other) {
    other.chunks.forEach((e) => addChunk(e));
  }

  void parse(String m3u) {
    final lines = m3u.split('\n');
    final format = lines.removeAt(0);
    assert(format == M3UHeaders.format, 'Invalid playlist format');

    double duration = 0;
    int id = 0;

    for(String line in lines) {
      line = line.trim();
      if (line == '') {
        continue;
      }
      if (line.startsWith('#')) {
        var parts = line.split(':');
        if (parts[0] == M3UHeaders.extInf) {
          parts = parts[1].split(',');
          duration = double.tryParse(parts[0]);
        } else {
          headers[parts[0]] = parts[1];
        }
      } else {
        var chunk = M3UChunk(
          _formatChunkUrl(line),
          mediaSequence + id,
          duration,
        );
        addChunk(chunk);
        id += 1;
      }
    }
  }

  void addChunk(M3UChunk chunk) {
    if(chunk.id > _lastChunkId) {
      chunks.add(chunk);
      _lastChunkId = chunk.id;
      _totalDuration += chunk.duration;
    }
  }

  String _formatChunkUrl(String chunkName) {
    var parts = url.split('/');
    parts[parts.length - 1] = chunkName;
    return parts.join('/');
  }

  String get hlsString {
    List<String> lines = [M3UHeaders.format];
    headers.forEach((key, value) => lines.add('$key:$value'));
    chunks.where((e) => e.file != null)
        .forEach((chunk) => lines.add(chunk.hlsString));
    return lines.join('\n');
  }

  Future<void> save() async {
    if(_file == null) {
      _file = await DefaultCacheManager().putFile(
        cacheKey,
        Uint8List(0),
        fileExtension: 'm3u8',
      );
    }
    _file.writeAsStringSync(hlsString);
  }

  String get cacheKey => '$url$mediaSequence';

  void clearCache() {
    chunks.forEach((e) => e.clearCache());
    DefaultCacheManager().removeFile(cacheKey);
  }
}


class M3UChunk {
  final String url;
  final double duration;
  final int id;
  File _file;

  M3UChunk(this.url,  this.id, this.duration);

  String get path => _file?.path;
  File get file => _file;

  Future<double> load() async {
    print('Loading: $url');
    _file = await DefaultCacheManager().getSingleFile(url);
    return duration;
  }

  String get hlsString {
    return "#EXTINF:$duration,\n$path";
  }

  void clearCache() {
    DefaultCacheManager().removeFile(url);
  }
}


/// Caches HLS Video stream including both playlist and files.

class HLSVideoCache {
  final M3UPlaylist _playlist;
  Timer _playlistCheckTimer;
  bool _disposed = false;

  static const Duration playlistCheckTimeout = Duration(seconds: 10);

  HLSVideoCache(url):
    assert (url != null),
    _playlist = M3UPlaylist(url);

  String get path => _playlist.path;
  File get file => _playlist.file;
  String get url => _playlist.url;
  Duration get duration => _playlist.bufferedDuration;

  Future<void> load() async {
    await _playlist.load();
    _playlist.setHeader(M3UHeaders.version, 4);
    _playlist.setHeader(M3UHeaders.playlistType, M3UHeaders.playlistTypeEvent);
    await _playlist.loadChunks(awaitMode: M3UPlaylist.awaitModeAll);
    _playlistCheckTimer = Timer.periodic(
      playlistCheckTimeout,
      (Timer timer) => _updatePlaylist()
    );
  }

  Future<void> _updatePlaylist() async {
    M3UPlaylist playlist = M3UPlaylist(url);
    await playlist.load();
    _playlist.merge(playlist);
    await _playlist.loadChunks();
  }

  void clear() {
    if (!_disposed) {
      _disposed = true;
      _playlistCheckTimer?.cancel();
      _playlist.clearCache();
    }
  }
}
