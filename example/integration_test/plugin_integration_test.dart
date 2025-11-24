// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sunmi_barcode_plugin/sunmi_barcode_plugin_method_channel.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('barcode scan test', (WidgetTester tester) async {
    final SunmiBarcodePlugin plugin = SunmiBarcodePlugin();

    // Create a completer to wait for the barcode event
    final Completer<String> barcodeCompleter = Completer<String>();

    // Listen to barcode events
    final StreamSubscription<String> subscription = plugin
        .onBarcodeScanned()
        .listen((barcode) {
          if (!barcodeCompleter.isCompleted) {
            barcodeCompleter.complete(barcode);
          }
        });

    // Trigger the test barcode
    await plugin.testBarcode();

    // Wait for the barcode event with a timeout
    final String receivedBarcode = await barcodeCompleter.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('Barcode event not received'),
    );

    // Verify the received barcode matches the expected value
    expect(receivedBarcode, '1111111111110');

    // Clean up
    await subscription.cancel();
  });
}
