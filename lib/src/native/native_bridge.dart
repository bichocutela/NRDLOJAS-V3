import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('nrdlojas/native');

  static Future<void> openComposeScreen({String screen = 'diagnostics'}) async {
    await _channel.invokeMethod<void>('openComposeScreen', <String, Object?>{
      'screen': screen,
    });
  }
}
