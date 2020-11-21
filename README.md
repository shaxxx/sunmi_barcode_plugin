# sunmi_barcode_plugin

Flutter plugin that wraps Sunmi Android SDK for integrated hardware barcode scanners.
Checked and working with [Sunmi L2 device](https://docs.sunmi.com/en/general-function-modules/scan/code-scanner-head-engineinfrared-scan-code/?q=scanner). [All methods from SDK](http://sunmi-ota.oss-cn-hangzhou.aliyuncs.com/DOC/resource/re_cn/%E6%89%AB%E7%A0%81%E5%A4%B4/L2%20userguide_EN0731.pdf) are supported.

## Getting Started

Create instance of the plugin 
```dart
  var sunmiPlugin = SunmiBarcodePlugin();
```
Then somewhere in your code you can check if device has Sunmi integrated scanner
```dart
 bool hasScanner = await sunmiPlugin.isScannerAvailable();
```
or find out exact scanner model number
```dart
int model = await sunmiPlugin.getScannerModel();
```
To get notified when barcode is scanned simply subscribe to stream
```dart
var barcodeSubscription = sunmiPlugin.onBarcodeScanned().listen((event) {
          print(event);
        });
```
To scan programatically you can use `scan` and `stop` methods.

If you don't have Sunmi device or just want to support more devices without implementing each SDK please check [flutter_barcode_listener](https://github.com/shaxxx/flutter_barcode_listener). 
