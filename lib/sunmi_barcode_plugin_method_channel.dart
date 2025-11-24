import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sunmi_barcode_plugin_platform_interface.dart';

/// Defines if key code is sent as key up or key down event
enum KeyAction {
  /// Simulates button down on keyboard
  actionDown,

  /// Simulates button up on keyboard
  actionUp,
}

/// An implementation of [SunmiBarcodePluginPlatform] that uses method channels.
class SunmiBarcodePlugin extends SunmiBarcodePluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  static const MethodChannel methodChannel = MethodChannel(
    'hr.integrator.flutter_sunmi_barcode_scanner',
  );

  @visibleForTesting
  final EventChannel eventChannel = const EventChannel(
    'hr.integrator.flutter_sunmi_barcode_scanner/events',
  );

  /// Customize the trigger key
  @override
  void sendKeyEvent(KeyAction keyAction, int keyCode) async {
    await methodChannel.invokeMethod('sendKeyEvent', {
      "key": keyAction.index,
      "code": keyCode,
    });
  }

  /// Start scanning
  @override
  void scan() async {
    await methodChannel.invokeMethod('scan');
  }

  /// Stop scanning
  @override
  void stop() async {
    await methodChannel.invokeMethod('stop');
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
  @override
  Future<int> getScannerModel() async {
    return (await methodChannel.invokeMethod('getScannerModel')).toInt();
  }

  /// Calls `getScannerModel` and returns true if it's greater than 100
  @override
  Future<bool> isScannerAvailable() async {
    var model = (await methodChannel.invokeMethod('getScannerModel')).toInt();
    //print(model);
    return (model > 100);
  }

  Stream<String>? _onBarcodeScanned;

  /// Subscribe to this stream to receive barcode as string when it's scanned.
  /// Make sure to cancel subscription when you're done.
  @override
  Stream<String> onBarcodeScanned() {
    _onBarcodeScanned ??= eventChannel.receiveBroadcastStream().map(
      (dynamic event) => event as String,
    );
    return _onBarcodeScanned!;
  }

  @override
  Future<void> testBarcode() async {
    await methodChannel.invokeMethod('testBarcode');
  }
}
