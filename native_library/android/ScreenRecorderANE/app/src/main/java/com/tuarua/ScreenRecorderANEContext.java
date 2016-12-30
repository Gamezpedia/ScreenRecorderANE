package com.tuarua;
import android.content.Intent;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.util.Log;

import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.TRSRActivityResultCallback;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.tuarua.screenrecorderane.ScreenRecorder;
import com.tuarua.screenrecorderane.Settings;
import com.tuarua.screenrecorderane.constants.FREScreenRecorderEvent;
import com.tuarua.screenrecorderane.constants.LogLevel;
import com.tuarua.utils.ANEhelper;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import static android.content.Context.MEDIA_PROJECTION_SERVICE;

/**
 * Created by Eoin Landy on 23/12/2016.
 * https://www.truiton.com/2015/05/capture-record-android-screen-using-mediaprojection-apis/
 */
public class ScreenRecorderANEContext extends FREContext {
    private int logLevel = LogLevel.QUIET;
    private static final String TAG = "ScreenRecorderANE";
    private static final String TRACE = "TRACE";
    private ANEhelper aneHelper = ANEhelper.getInstance();
    private MediaProjectionManager mediaProjectionManager;
    private ScreenRecorder recorder;
    private static final int REQUEST_CODE = 1;
    private String savePath;
    private String fileName;

    public ScreenRecorderANEContext() {
    }

    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functionsToSet = new HashMap<>();
        functionsToSet.put("setLogLevel",new setLogLevel());
        functionsToSet.put("isSupported", new isSupported());
        functionsToSet.put("initCapture", new initCapture());
        functionsToSet.put("startCapture", new startCapture());
        functionsToSet.put("stopCapture", new stopCapture());
        return functionsToSet;
    }

    @Override
    public void dispose() {

    }

    private class isSupported implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return aneHelper.getFREObjectFromBool((android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP));
        }
    }

    private class initCapture implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            mediaProjectionManager = (MediaProjectionManager)
                    freContext.getActivity().getSystemService(MEDIA_PROJECTION_SERVICE);
            return null;
        }
    }

    private class startCapture implements FREFunction, TRSRActivityResultCallback {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {

            FREObject settingsProps = freObjects[0];
            FREObject savePathAS = freObjects[1];
            FREObject fileNameAS = freObjects[2];

            Settings.width = aneHelper.getIntFromFREObject(aneHelper.getFREObjectProperty(settingsProps, "width"));
            Settings.height = aneHelper.getIntFromFREObject(aneHelper.getFREObjectProperty(settingsProps, "height"));
            Settings.bitrate = aneHelper.getIntFromFREObject(aneHelper.getFREObjectProperty(settingsProps, "bitrate"));
            Settings.dpi = aneHelper.getIntFromFREObject(aneHelper.getFREObjectProperty(settingsProps, "dpi"));
            Settings.fps = aneHelper.getIntFromFREObject(aneHelper.getFREObjectProperty(settingsProps, "fps"));

            savePath = aneHelper.getStringFromFREObject(savePathAS);
            fileName = aneHelper.getStringFromFREObject(fileNameAS);

            Intent captureIntent = mediaProjectionManager.createScreenCaptureIntent();
            AndroidActivityWrapper.GetAndroidActivityWrapper().addActivityResultListener(this);
            freContext.getActivity().startActivityForResult(captureIntent, REQUEST_CODE);
            return null;
        }

        @Override
        public void onActivityResult(int requestCode, int resultCode, Intent data) {
            if (resultCode == 0) {
                dispatchStatusEventAsync("", FREScreenRecorderEvent.PERMISSION_DENIED);
                return;
            }

            dispatchStatusEventAsync("", FREScreenRecorderEvent.PERMISSION_GRANTED);

            MediaProjection mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, data);
            if (mediaProjection == null) {
                dispatchStatusEventAsync("", FREScreenRecorderEvent.NOT_AVAILABLE);
                return;
            }
            File file = new File(savePath, fileName + ".mp4");

            recorder = new ScreenRecorder(Settings.width, Settings.height, Settings.bitrate, Settings.dpi,
                    mediaProjection, file.getAbsolutePath(), Settings.fps);
            recorder.start();
            dispatchStatusEventAsync("", FREScreenRecorderEvent.STARTED);
        }
    }


    private class stopCapture implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            recorder.quit();
            recorder = null;
            dispatchStatusEventAsync("", FREScreenRecorderEvent.STOPPED);
            return null;
        }
    }

    private class setLogLevel implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            logLevel = aneHelper.getIntFromFREObject(freObjects[0]);
            return null;
        }
    }

    private void trace(String msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.d(TAG, String.valueOf(msg));
            dispatchStatusEventAsync(msg, TRACE);
        }

    }

    private void trace(int msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.d(TAG, String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), TRACE);
        }
    }

    private void trace(boolean msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.d(TAG, String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), TRACE);
        }
    }



}
