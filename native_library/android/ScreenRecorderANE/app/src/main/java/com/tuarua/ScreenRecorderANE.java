package com.tuarua;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

/**
 * Created by Eoin Landy on 23/12/2016.
 * https://www.truiton.com/2015/05/capture-record-android-screen-using-mediaprojection-apis/
 */

public class ScreenRecorderANE implements FREExtension {
    public static ScreenRecorderANEContext extensionContext;
    @Override
    public void initialize() {

    }

    @Override
    public FREContext createContext(String s) {
        return extensionContext = new ScreenRecorderANEContext();
    }

    @Override
    public void dispose() {

    }
}
