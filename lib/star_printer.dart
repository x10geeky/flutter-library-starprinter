import 'dart:async';

import 'package:flutter/services.dart';

class StarPrinter {
  static const MethodChannel _channel = const MethodChannel('star_printer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    // final String version = await _channel.invokeMethod('getPlatformVersion', <String, Object>{'url': 'www.apple.com'});
    return version;
  }

  static Future<String> get getPrinters async {
    print("1");
    final String version = await _channel.invokeMethod('getPrinters');
    print("2");
    return version;
  }
}
