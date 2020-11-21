package hr.integrator.sunmi_barcode_plugin;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;
import android.view.KeyEvent;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** SunmiBarcodePlugin */
public class SunmiBarcodePlugin implements MethodCallHandler, StreamHandler, FlutterPlugin {

  private Context applicationContext;
  private BroadcastReceiver scannerServiceReceiver;
  private MethodChannel methodChannel;
  private EventChannel eventChannel;

  /** Plugin registration. */
  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    final SunmiBarcodePlugin instance = new SunmiBarcodePlugin();
    instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    ScannerServiceConnection.getInstance().connectScannerService(registrar.context());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
    this.applicationContext = applicationContext;
    methodChannel = new MethodChannel(messenger, "hr.integrator.flutter_sunmi_barcode_scanner");
    eventChannel = new EventChannel(messenger, "hr.integrator.flutter_sunmi_barcode_scanner/events");
    eventChannel.setStreamHandler(this);
    methodChannel.setMethodCallHandler(this);
    ScannerServiceConnection.getInstance().connectScannerService(applicationContext);
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    onCancel(null);
    ScannerServiceConnection.getInstance().disconnectScannerService(applicationContext);
    applicationContext = null;
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
    eventChannel.setStreamHandler(null);
    eventChannel = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("scan")) {
      ScannerServiceConnection.getInstance().scan();
      result.success(null);
    } else if (call.method.equals("stop")) {
      ScannerServiceConnection.getInstance().stop();
      result.success(null);
    } else if (call.method.equals("getScannerModel")) {
      int model =  ScannerServiceConnection.getInstance().getScannerModel();
      result.success(model);
    } else if (call.method.equals("sendKeyEvent")) {
      int action = call.argument("key");
      int code = call.argument("code");
      ScannerServiceConnection.getInstance().sendKeyEvent(new KeyEvent(action,code));
      result.success(null);
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onListen(Object arguments, EventSink events) {
    scannerServiceReceiver = createScannerServiceReceiver(events);
    applicationContext.registerReceiver(
            scannerServiceReceiver, new IntentFilter("com.sunmi.scanner.ACTION_DATA_CODE_RECEIVED"));
  }

  @Override
  public void onCancel(Object arguments) {
    applicationContext.unregisterReceiver(scannerServiceReceiver);
    scannerServiceReceiver = null;
  }

  private BroadcastReceiver createScannerServiceReceiver(final EventSink events) {
    return new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        String data = intent.getStringExtra("data");
        events.success(data);
      }
    };
  }
}