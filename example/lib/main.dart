import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sunmi_barcode_plugin/sunmi_barcode_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _modelVersion = 'Unknown';
  var sunmiBarcodePlugin = SunmiBarcodePlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    sunmiBarcodePlugin.onBarcodeScanned().listen((event) {
      print(event);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String modelVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      modelVersion = (await sunmiBarcodePlugin.getScannerModel()).toString();
    } on PlatformException {
      modelVersion = 'Failed to get model version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _modelVersion = modelVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await sunmiBarcodePlugin.isScannerAvailable()) {
              sunmiBarcodePlugin.scan();
            }
          },
          child: Icon(Icons.scanner),
        ),
        appBar: AppBar(
          title: const Text('Sunmi Barcode Plugin'),
        ),
        body: Center(
          child: Text('Scanner model: $_modelVersion\n'),
        ),
      ),
    );
  }
}
