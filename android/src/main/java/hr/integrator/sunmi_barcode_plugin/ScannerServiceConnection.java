package hr.integrator.sunmi_barcode_plugin;

import android.app.Service;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.view.KeyEvent;

import com.sunmi.scanner.IScanInterface;

public class ScannerServiceConnection {

    private static ScannerServiceConnection mScannerServiceConnection = new ScannerServiceConnection();
    private static final String SERVICE＿PACKAGE = "com.sunmi.scanner";
    private static final String SERVICE＿ACTION = "com.sunmi.scanner.IScanInterface";

    String TAG = "BarcodeServiceConnection";
    private ScannerServiceConnection() {

    }

    public static ScannerServiceConnection getInstance() {
        return mScannerServiceConnection;
    }

    private IScanInterface scannerService;

    public void connectScannerService(Context context) {
        Intent intent = new Intent();
        intent.setPackage(SERVICE＿PACKAGE);
        intent.setAction(SERVICE＿ACTION);
        context.getApplicationContext().bindService(intent, connService, Service.BIND_AUTO_CREATE);
    }

    public void disconnectScannerService(Context context) {
        if (scannerService != null) {
            context.getApplicationContext().unbindService(connService);
            scannerService = null;
        }
    }

    private ServiceConnection connService = new ServiceConnection() {

        @Override
        public void onServiceDisconnected(ComponentName name) {
            scannerService = null;
            Log.d(TAG, "Sumi barcode service disconnected " + this.hashCode());
        }

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            scannerService = IScanInterface.Stub.asInterface(service);
            if (scannerService != null) {
                Log.d(TAG, "Connected to Sunmi scanner service");
            }
            else {
                Log.e(TAG, "Failed to connect to Sunmi scanner service");
            }
        }
    };

    public void sendKeyEvent(KeyEvent key){
        if (scannerService == null) return;
        try {
            scannerService.sendKeyEvent(key);
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }


    public void scan(){
        if (scannerService == null) return;
        try {
            scannerService.scan();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    public void stop(){
        if (scannerService == null) return;
        try {
            scannerService.stop();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
    }

    public int getScannerModel(){
        if (scannerService == null) return 0;
        try {
            return scannerService.getScannerModel();
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        return 0;
    }

}