import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_printer/star_printer.dart';

void main() {
  const MethodChannel channel = MethodChannel('star_printer');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await StarPrinter.platformVersion, '42');
  });
}
