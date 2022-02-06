import 'dart:async';

import 'package:flutter/services.dart';

/// Defines if key code is sent as key up or key down event
enum KeyAction {
  /// Simulates button down on keyboard
  actionDown,

  /// Simulates button up on keyboard
  actionUp
}

/// Plugin that wraps Sunmi Android SDK for integrated barcode scanner
class SunmiBarcodePlugin {
  static const MethodChannel _channel =
      const MethodChannel('hr.integrator.flutter_sunmi_barcode_scanner');
  EventChannel _eventChannel =
      const EventChannel('hr.integrator.flutter_sunmi_barcode_scanner/events');

  /// Customize the trigger key
  void sendKeyEvent(KeyAction keyAction, int keyCode) async {
    await _channel.invokeMethod(
        'sendKeyEvent', {"key": keyAction.index, "code": keyCode});
  }

  /// Start scanning
  void scan() async {
    await _channel.invokeMethod('scan');
  }

  /// Stop scanning
  void stop() async {
    await _channel.invokeMethod('stop');
  }

  /// Returns model number of the hardware scanner.
  /// 100 → NONE
  /// 101 → P2Lite/V2Pro/P2Pro(em1365/BSM1825)
  /// 102 → L2-newland(EM2096)
  /// 103 → L2-zabra(SE4710)
  /// 104 → L2-HoneyWell(N3601)
  /// 105 → L2-HoneyWell(N6603)
  /// 106 → L2-Zabra(SE4750)
  /// 107 → L2-Zabra(EM1350)
  Future<int> getScannerModel() async {
    return (await _channel.invokeMethod('getScannerModel')).toInt();
  }

  /// Calls `getScannerModel` and returns true if it's greater than 100
  Future<bool> isScannerAvailable() async {
    var model = (await _channel.invokeMethod('getScannerModel')).toInt();
    print(model);
    return (model > 100);
  }

  Stream<String?>? _onBarcodeScanned;

  /// Subscribe to this stream to receive barcode as string when it's scanned.
  /// Make sure to cancel subscription when you're done.
  Stream<String?>? onBarcodeScanned() {
    if (_onBarcodeScanned == null) {
      _onBarcodeScanned = _eventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => event as String?);
    }
    return _onBarcodeScanned;
  }
}
