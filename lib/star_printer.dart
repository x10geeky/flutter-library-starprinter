import 'dart:async';

import 'package:flutter/services.dart';

class StarPrinter {
  static const MethodChannel _channel = const MethodChannel('star_printer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> getPrinters() async {
    final String printers = await _channel.invokeMethod('getPrinters');
    return printers;
  }

  static Future<bool> printerWithText() async {
    final bool isSuccess = await _channel.invokeMethod('printerWithText');
    return isSuccess;
  }

  static Future<bool> printerWithImage({String base64}) async {
    final bool isSuccess = await _channel.invokeMethod('printerWithImage', <String, Object>{'base64': base64, 'drawer': false});
    return isSuccess;
  }

  static Future<bool> openCashDrawer() async {
    final bool isSuccess = await _channel.invokeMethod('openCashDrawer');
    return isSuccess;
  }

}
