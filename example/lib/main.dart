import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:star_printer/star_printer.dart';
import 'package:star_printer/printer_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  PrinterModel printer;

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
      list.forEach((item) {
        item.forEach((k, v) => print("$k: $v"));
      });
    } on PlatformException {
      print('Failed to get platform version.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Star Micro Printer'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(printer == null ? 'Unknow' : printer.modelName),
              RaisedButton(
                child: Text('Find Printer'),
                onPressed: onPressedFindPrinter,
              ),
              /*
              RaisedButton(
                child: Text('Print with Text'),
                onPressed: onPressedPrintWithText,
              ),
               */
              RaisedButton(
                child: Text('Print with Image'),
                onPressed: onPressedPrintWithImage,
              ),
              RaisedButton(
                child: Text('Open Cash Drawer'),
                onPressed: onPressedOpenCashDrawer,
              ),
              /*
              RaisedButton(
                child: Text('Clean'),
                onPressed: onPressedClean,
              ),
               */
            ],
          ),
        ),
      ),
    );
  }

  void onPressedFindPrinter() async {
    List result;
    List<PrinterModel> printers = List<PrinterModel>();
    try {
      /*
      result = [
        {"modelName": "TSP654 (STR_T-001)", "macAddress": "00:11:62:06:8b:a0", "portName": "TCP:192.168.1.111"},
        {"modelName": "TSP654 (STR_T-002)", "macAddress": "00:11:62:06:8b:a0", "portName": "TCP:192.168.1.111"}
      ];
       */
      result = await StarPrinter.printers;
      result.forEach((item) {
        printers.add(PrinterModel(modelName: item["modelName"],macAddress: item["macAddress"],portName: item["portName"]));
      });

      onOpenDialogPrinter(printers);
    } on PlatformException {
      //printers = 'Failed to get platform version.';
    }
  }

  void onOpenDialogPrinter(List<PrinterModel> printers) {
    final context = navigatorKey.currentState.overlay.context;
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Plase Choose Printer"),
        content: Column(
          children: printers
              .asMap()
              .map(
                (int i, PrinterModel value) {
                  return MapEntry(
                    i,
                    RaisedButton(
                      child: Text(value.modelName, style: TextStyle(fontSize: 20)),
                      onPressed: () => onSelectedPrinter(value),
                    ),
                  );
                },
              )
              .values
              .toList(),
        ),
      ),
    );
  }

  void onSelectedPrinter(PrinterModel value) {
    final context = navigatorKey.currentState.overlay.context;
    Navigator.maybePop(context);
    print(value.modelName);

    setState(() {
      printer = value;
    });
  }

  void onPressedPrintWithText() async {
    if (printer != null) {
      var isSuccess = await StarPrinter.printerWithText(printer: printer.toJson());
    }
  }

  void onPressedPrintWithImage() async {
    if (printer != null) {
      ByteData bytes = await rootBundle.load('assets/images/invoice.png');
      var buffer = bytes.buffer;
      var img = base64.encode(Uint8List.view(buffer));
      var isSuccess = await StarPrinter.printerWithImage(printer: printer.toJson(), base64: img);
    }
  }

  void onPressedOpenCashDrawer() async {
    var isSuccess = await StarPrinter.openCashDrawer();
  }

  void onPressedClean() {
    setState(() {
      printer = null;
    });
  }
}
