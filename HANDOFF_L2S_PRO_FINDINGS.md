# L2S_PRO Scanner Investigation Findings

**Date:** 2026-03-02
**Device:** Sunmi L2S_PRO
**Goal:** Diagnose why the plugin doesn't work on L2S_PRO

---

## Summary

The L2S_PRO is a new Sunmi device that behaves differently from older Sunmi devices (L2, P2, etc.). The main issue is that `bindService()` returns `false` when trying to connect to the scanner service, making programmatic scanner control impossible. However, barcode scanning via hardware button still works through broadcasts.

---

## What Works

### ✅ Barcode Broadcast Reception
- The scanner correctly sends broadcasts when the hardware scan button is pressed
- Broadcast action: `com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED`
- Data extra key: `data`
- The plugin's EventChannel correctly receives barcode data when scanned

**Evidence from logcat:**
```
Broadcast received! Action: com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED
Barcode data: 7237842225343
```

### ✅ Scanner Package Exists
- Package `com.sunmi.scanner` IS installed on the device
- Confirmed via `pm list packages`

---

## What Does NOT Work

### ❌ Service Binding
All three binding methods fail:

1. **Explicit component intent** to `com.sunmi.scanner.service.ScannerService`
2. **Implicit intent** with action `com.sunmi.scanner.IScanInterface`
3. **New interface** at `com.sunmi.scanner.scannerdevice.service.IScanManager`

**Evidence from logcat:**
```
Method 1 (explicit component): bindService result: false for com.sunmi.scanner.service.ScannerService
Method 2 (implicit): bindService result: false for action=com.sunmi.scanner.IScanInterface
Method 3 (new interface): bindService result: false for com.sunmi.scanner.scannerdevice.service.IScanManager
```

### ❌ Programmatic Scan Control
- `scan()` method cannot trigger scanning (requires service connection)
- `stop()` method cannot stop scanning (requires service connection)

### ❌ getScannerModel() Returns 0
- Because service binding fails, `getScannerModel()` always returns 0
- This breaks the existing detection pattern used by the app (checking if model > 100)

---

## Technical Findings

### Scanner Hardware
The L2S_PRO uses a **Zebra scanner** internally (not Newland or other variants used in older L2 devices).

**Evidence from logcat:**
```
ZebraScanner: se4500_streamon
ZebraScannerJNI: Java_com_zebra_zebrascanner_ZebraScanner_...
```

### Available Services in com.sunmi.scanner
The package exposes multiple services:

| Service Class | Action | Status |
|--------------|--------|--------|
| `.service.ScannerService` | `com.sunmi.scanner.IScanInterface` | Cannot bind |
| `.scannerdevice.service.IScanManager` | `com.sunmi.scanner.IScanManagerInterface` | Cannot bind |
| `.rfid.service.RfidService` | `com.sunmi.scanner.IScanRFIDInterface` | Not tested |

### Broadcast Flow
When scan button is pressed:
1. Zebra scanner hardware activates
2. `darren-scanUtils` sends broadcast: `com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED`
3. Broadcast includes extra `data` with barcode content

**Evidence from logcat:**
```
darren-scanUtils: sendCodeBroadcast: action:com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED, dataKey:data, byteKey:source_byte
ActivityManager: Sending non-protected broadcast com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED from system 1586:com.sunmi.scanner/u0a99
```

### Why bindService Fails
Likely reasons (not confirmed):
- Service is not exported (`android:exported="false"`)
- Service requires signature-level permission
- Sunmi restricted third-party app access to scanner service on newer devices

---

## The Core Problem

The app uses `getScannerModel()` to detect if a Sunmi scanner is available:
- **Old devices (L2, P2, etc.):** Service binds successfully, returns model code 101-107
- **L2S_PRO:** Service binding fails, returns 0 (looks like "no scanner")

This means the app cannot distinguish between:
1. A device without any Sunmi scanner
2. A device with a Sunmi scanner that blocks service binding (L2S_PRO)

---

## Existing Scanner Model Codes

From AIDL comments:
- 100: NONE
- 101: P2Lite/V2Pro/P2Pro
- 102: L2-newland
- 103: L2-zebra
- 104-107: Other L2 variants

---

## Files Modified During Investigation

Diagnostic logging was added to:
- `android/src/main/java/hr/integrator/sunmi_barcode_plugin/ScannerServiceConnection.java`
- `android/src/main/java/hr/integrator/sunmi_barcode_plugin/SunmiBarcodePlugin.java`

New methods added (for diagnosis):
- `isConnected()` - check if service is connected
- `getServiceInfo()` - get diagnostic string
- `hasSunmiScanner()` - check if package exists
- `getScannerModelWithFallback()` - attempt fallback detection

These changes are in the working directory but not committed.

---

## Questions to Address

1. How to reliably detect Sunmi scanner presence on devices where service binding fails?
2. Should the plugin support "broadcast-only" mode for newer devices?
3. Is there an alternative API for programmatic scanning on L2S_PRO?
4. Should we check for package existence as a fallback detection method?
