import 'dart:async';

import 'package:flutter/services.dart';

enum KeyAction { actionDown, actionUp }

class SunmiBarcodePlugin {
  static const MethodChannel _channel =
      const MethodChannel('hr.integrator.flutter_sunmi_barcode_scanner');
  EventChannel _eventChannel =
      const EventChannel('hr.integrator.flutter_sunmi_barcode_scanner/events');

  void sendKeyEvent(KeyAction keyAction, int keyCode) async {
    await _channel.invokeMethod(
        'sendKeyEvent', {"key": keyAction.index, "code": keyCode});
  }

  void scan() async {
    await _channel.invokeMethod('scan');
  }

  void stop() async {
    await _channel.invokeMethod('stop');
  }

  Future<int> getScannerModel() async {
    return (await _channel.invokeMethod('getScannerModel')).toInt();
  }

  Future<bool> isScannerAvailable() async {
    var model = (await _channel.invokeMethod('getScannerModel')).toInt();
    print(model);
    return (model > 100);
  }

  Stream<String> _onBarcodeScanned;

  Stream<String> onBarcodeScanned() {
    if (_onBarcodeScanned == null) {
      _onBarcodeScanned = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => event as String);
    }
    return _onBarcodeScanned;
  }
}
