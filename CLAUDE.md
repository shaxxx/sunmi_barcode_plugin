# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter plugin that wraps the Sunmi Android SDK for integrated hardware barcode scanners. It is designed for Sunmi devices (e.g., L2) and provides a Dart API to control the hardware scanner.

**Platform:** Android-only (no iOS support)

## Commands

### Dart/Flutter
```bash
# Get dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run Dart unit tests
flutter test

# Run specific test file
flutter test test/sunmi_barcode_plugin_method_channel_test.dart
```

### Android (from example/android/)
```bash
# Run Android unit tests
./gradlew testDebugUnitTest
```

### Example app
```bash
cd example
flutter pub get
flutter run  # Requires Sunmi device or emulator
```

## Architecture

The plugin follows Flutter's federated plugin pattern:

```
lib/
├── sunmi_barcode_plugin_platform_interface.dart  # Abstract platform interface
└── sunmi_barcode_plugin_method_channel.dart      # Method channel implementation
```

**Communication flow:**
1. Dart → `SunmiBarcodePlugin` (method channel) → Android native code
2. Android → `SunmiBarcodePlugin.java` → `ScannerServiceConnection` (singleton) → Sunmi scanner service via AIDL
3. Barcode events: Sunmi scanner → BroadcastReceiver → EventChannel → Dart stream

### Key Components

- **Method Channel:** `hr.integrator.flutter_sunmi_barcode_scanner`
- **Event Channel:** `hr.integrator.flutter_sunmi_barcode_scanner/events`
- **Broadcast Action:** `com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED`

### Android Native Layer

- `SunmiBarcodePlugin.java` - Handles method calls and event stream registration
- `ScannerServiceConnection.java` - Singleton that binds to Sunmi's `IScanInterface` AIDL service
- `IScanInterface.aidl` - Defines the Sunmi scanner service API (scan, stop, sendKeyEvent, getScannerModel)

### Scanner Models
- 100: NONE
- 101: P2Lite/V2Pro/P2Pro
- 102: L2-newland
- 103: L2-zebra
- 104-107: Other L2 variants

## Testing Notes

- Dart unit tests mock the method channel but are mostly commented out
- Android unit tests use Mockito and require `./gradlew testDebugUnitTest` from `example/android/`
- A `testBarcode()` method exists for simulating barcode scans during development
