import 'package:flutter/services.dart';

const _platform = const MethodChannel('MP_CHANNEL');

Future<bool> isTv() async {
  return _platform.invokeMethod<bool>('isTv');
}

Future<void> enablePip() async {
  return _platform.invokeMethod('enablePip');
}

Future<void> disablePip() async {
  return _platform.invokeMethod('disablePip');
}
