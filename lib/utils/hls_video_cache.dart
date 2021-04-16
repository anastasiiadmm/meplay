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

enum ChunkLoadMode {
  waitAll,   // load all at once and waits
  waitEach,  // load one by one and waits
}

class M3UPlaylist {
  final String url;
  final ChunkLoadMode _waitMode;
  final bool _cached;
  List<M3UChunk> _chunks = [];
  Map<String, String> _headers = {};
  File _file;
  int _mediaSequence;
  int _version;
  double _targetDuration;
  int _lastChunkId = -1;
  double _bufferedDuration = 0;
  double _totalDuration = 0;
  bool _disposed = false;

  M3UPlaylist(this.url, {
    bool cached: true,
    ChunkLoadMode waitMode: ChunkLoadMode.waitAll,
    Map<String, String> headers,
  })
      : assert(url != null),
        assert(cached != null),
        assert(waitMode != null),
        _cached = cached,
        _waitMode = waitMode {
    if(headers != null) _headers.addAll(headers);
  }

  Duration get bufferedDuration {
    return Duration(microseconds:(_bufferedDuration * 1000000).floor());
  }

  Duration get totalDuration {
    return Duration(microseconds:(_totalDuration * 1000000).floor());
  }

  String getHeader(String key, {String defaultValue}) {
    if (_headers.containsKey(key)) return _headers[key];
    return defaultValue;
  }

  void setHeader(String key, dynamic value) {
    _headers[key] = value.toString();
  }

  int get mediaSequence {
    _mediaSequence ??= int.tryParse(getHeader(M3UHeaders.mediaSequence));
    return _mediaSequence;
  }

  set mediaSequence(int value) {
    setHeader(M3UHeaders.mediaSequence, '$value');
    _mediaSequence = value;
  }

  double get targetDuration {
    _targetDuration ??= double.tryParse(getHeader(M3UHeaders.targetDuration));
    return _targetDuration;
  }

  set targetDuration(double value) {
    setHeader(M3UHeaders.targetDuration, '$value');
    _targetDuration = value;
  }

  int get version {
    _version ??= int.tryParse(getHeader(M3UHeaders.version));
    return _version;
  }

  set version(int value) {
    _version = value;
    setHeader(M3UHeaders.version, '$value');
  }

  Map<String, String> get headers => _headers;
  List<M3UChunk> get chunks => _chunks;
  File get file => _file;
  String get path => _file?.path;

  Future<void> load() async {
    if(_disposed) return;
    await _loadPlaylist();
    if(_cached) {
      await _save();
      await _loadChunks();
      if(_disposed) _clearCache();
    }
  }

  Future<void> merge(M3UPlaylist other) async {
    if(_disposed) return;
    other.chunks.forEach((chunk) {addChunk(chunk);});
    if(_cached) {
      await _loadChunks();
      if(_disposed) _clearCache();
    }
  }

  Future<void> _loadPlaylist() async {
    print('HLS Playlist: $url');
    final response = await http.get(url);
    if (response.statusCode == 200) _parse(response.body);
  }

  Future<void> _loadChunks() async {
    final chunks = _chunks.where((chunk) => chunk.file == null);
    switch (_waitMode) {
      case ChunkLoadMode.waitAll:
        await Future.wait(chunks.map((chunk) async {
          await chunk.load();
          _bufferedDuration += chunk.duration;
        }));
        await _save();
        break;
      case ChunkLoadMode.waitEach:
        await Future.forEach(chunks, (chunk) async {
          await chunk.load();
          _bufferedDuration += chunk.duration;
          await _save();
        });
        break;
      default:
        throw Exception('Invalid mode');
    }
  }

  void _parse(String m3u) {
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
          _makeChunkUrl(line),
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

  String _makeChunkUrl(String chunkName) {
    var parts = url.split('/');
    parts[parts.length - 1] = chunkName;
    return parts.join('/');
  }

  String get hlsString {
    List<String> lines = [M3UHeaders.format];
    headers.forEach((key, value) => lines.add('$key:$value'));
    chunks.where((chunk) => chunk.file != null)
        .forEach((chunk) => lines.add(chunk.hlsString));
    return lines.join('\n');
  }

  Future<void> _save() async {
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

  void dispose() {
    _disposed = true;
    _clearCache();
  }

  void _clearCache() {
    if (_file != null) {
      DefaultCacheManager().removeFile(cacheKey);
      _file = null;
    }
    _chunks.forEach((chunk) {chunk.dispose();});
  }
}


class M3UChunk {
  final String url;
  final double duration;
  final int id;
  File _file;
  bool _disposed = false;

  M3UChunk(this.url, this.id, this.duration);

  String get path => _file?.path;
  File get file => _file;

  Future<void> load() async {
    if(_disposed) return;
    print('HLS chunk: $url');
    _file = await DefaultCacheManager().getSingleFile(url);
    if(_disposed) _clearCache();
  }

  String get hlsString {
    return "#EXTINF:$duration,\n$path";
  }

  void dispose() {
    _disposed = true;
    _clearCache();
  }

  void _clearCache() {
    if(_file != null) {
      DefaultCacheManager().removeFile(url);
      _file = null;
    }
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
    _playlist = M3UPlaylist(url, headers: {
      M3UHeaders.version: '4',
      M3UHeaders.playlistType: M3UHeaders.playlistTypeEvent,
    });

  String get path => _playlist.path;
  File get file => _playlist.file;
  String get url => _playlist.url;
  Duration get duration => _playlist.bufferedDuration;

  Future<void> load() async {
    if(_disposed) return;
    await _playlist.load();
    if(_disposed) _playlist.dispose();
    else _playlistCheckTimer = Timer.periodic(
      playlistCheckTimeout,
      (Timer timer) {_updatePlaylist();},
    );
    if(_disposed) _dispose();
  }

  Future<void> _updatePlaylist() async {
    M3UPlaylist playlist = M3UPlaylist(url, cached: false,);
    await playlist.load();
    await _playlist.merge(playlist);
  }

  void clear() {
    print('HLS cache dispose');
    _disposed = true;
    _dispose();
  }

  void _dispose() {
    _playlist.dispose();
    _playlistCheckTimer?.cancel();
  }
}
