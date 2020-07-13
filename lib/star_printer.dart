import 'dart:async';
import 'package:flutter/services.dart';

class StarPrinter {
  static const MethodChannel _channel = const MethodChannel('star_printer');

  static Future<List> get platformVersion async {
    return await _channel.invokeMethod('getPlatformVersion');
  }

  static Future<bool> get delay async {
    return await Future.delayed(const Duration(seconds: 10));
  }

  static Future<List> get printers async {
    return _channel.invokeMethod('getPrinters');
  }

  static Future<bool> printerWithText({Map printer}) async {
    return await _channel.invokeMethod('printerWithText', <String, Object>{'printer': printer});
  }

  static Future<bool> printerWithImage({Map printer, String base64}) async {
    return _channel.invokeMethod('printerWithImage', <String, Object>{'printer': printer, 'base64': base64, 'drawer': false});
  }

  static Future<bool> openCashDrawer() async {
    return _channel.invokeMethod('openCashDrawer');
  }

}
