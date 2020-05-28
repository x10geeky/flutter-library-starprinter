import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:star_printer/star_printer.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _printers = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    List list;
    try {
      list = await StarPrinter.platformVersion;
      print(list);
      list.forEach((item){
        item.forEach((k, v) => print("$k: $v"));
      });
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Star Micro Printer'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_printers),
              RaisedButton(
                child: Text('Find Printer'),
                onPressed: onPressedFindPrinter,
              ),
              RaisedButton(
                child: Text('Print with Text'),
                onPressed: onPressedPrintWithText,
              ),
              RaisedButton(
                child: Text('Print with Image'),
                onPressed: onPressedPrintWithImage,
              ),
              RaisedButton(
                child: Text('Open Cash Drawer'),
                onPressed: onPressedOpenCashDrawer,
              ),
              RaisedButton(
                child: Text('Clean'),
                onPressed: onPressedClean,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressedFindPrinter() async {
    var printers = "";
    try {
      printers = await StarPrinter.getPrinters();
    } on PlatformException {
      printers = 'Failed to get platform version.';
    }
    setState(() {
      _printers = printers;
    });
  }

  void onPressedPrintWithText() async {
    var isSuccess = await StarPrinter.printerWithText();
  }

  void onPressedPrintWithImage() async {
    ByteData bytes = await rootBundle.load('assets/images/invoice.png');
    var buffer = bytes.buffer;
    var img = base64.encode(Uint8List.view(buffer));
    var isSuccess = await StarPrinter.printerWithImage(base64: img);
  }

  void onPressedOpenCashDrawer() async {
    var isSuccess = await StarPrinter.openCashDrawer();
  }

  void onPressedClean() {
    setState(() {
      _printers = "";
    });
  }

}
