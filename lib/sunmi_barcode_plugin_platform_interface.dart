import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sunmi_barcode_plugin_method_channel.dart';

abstract class SunmiBarcodePluginPlatform extends PlatformInterface {
  /// Constructs a SunmiBarcodePluginPlatform.
  SunmiBarcodePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SunmiBarcodePluginPlatform _instance = SunmiBarcodePlugin();

  /// The default instance of [SunmiBarcodePluginPlatform] to use.
  ///
  /// Defaults to [SunmiBarcodePlugin].
  static SunmiBarcodePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SunmiBarcodePluginPlatform] when
  /// they register themselves.
  static set instance(SunmiBarcodePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Customize the trigger key
  void sendKeyEvent(KeyAction keyAction, int keyCode) async {
    throw UnimplementedError(
      'sendKeyEvent(keyAction, keyCode) has not been implemented.',
    );
  }

  /// Start scanning
  void scan() async {
    throw UnimplementedError('scan() has not been implemented.');
  }

  /// Stop scanning
  void stop() async {
    throw UnimplementedError('stop() has not been implemented.');
  }

  Future<int> getScannerModel() async {
    throw UnimplementedError('getScannerModel() has not been implemented.');
  }

  /// Calls `getScannerModel` and returns true if it's greater than 100
  Future<bool> isScannerAvailable() async {
    throw UnimplementedError('isScannerAvailable() has not been implemented.');
  }

  /// Subscribe to this stream to receive barcode as string when it's scanned.
  /// Make sure to cancel subscription when you're done.
  Stream<String> onBarcodeScanned() {
    throw UnimplementedError('onBarcodeScanned() has not been implemented.');
  }

  Future<void> testBarcode() {
    throw UnimplementedError('testBarcode() has not been implemented.');
  }
}
