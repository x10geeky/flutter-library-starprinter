import 'package:flutter/material.dart';
import 'dart:async';

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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    /*
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await StarPrinter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
     */

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    /*
    setState(() {
      _platformVersion = platformVersion;
    });
     */
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                child: Text('Print...'),
                onPressed: onPressedPrint,
              ),
              RaisedButton(
                child: Text('Clean'),
                onPressed: onPressedClean,
              )
            ],
          ),
        ),
      ),
    );
  }

  void onPressedFindPrinter() async {
    var printers = "";
    try {
      printers = await StarPrinter.getPrinters;
    } on PlatformException {
      printers = 'Failed to get platform version.';
    }
    setState(() {
      _printers = printers;
    });
  }

  void onPressedPrint() async {

  }

  void onPressedClean() {
    setState(() {
      _printers = "";
    });
  }

}
