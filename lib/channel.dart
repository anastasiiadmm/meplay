import 'package:flutter/services.dart';

const _platform = const MethodChannel('MP_CHANNEL');
bool _isTv;

Future<bool> isTv() async {
  if (_isTv == null) {
    _isTv = await _platform.invokeMethod<bool>('isTv');
  }
  return _isTv;
}

Future<void> enablePip() async {
  return _platform.invokeMethod('enablePip');
}

Future<void> disablePip() async {
  return _platform.invokeMethod('disablePip');
}
