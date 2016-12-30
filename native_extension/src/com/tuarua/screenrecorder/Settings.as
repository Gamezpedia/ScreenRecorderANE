/**
 * Created by Eoin Landy on 24/12/2016.
 */
package com.tuarua.screenrecorder {
public class Settings extends Object {
    public var width:int = 1280;
    public var height:int = 720;
    public var bitrate:int = 2000000; //2Mbps
    public var dpi:int = 1;
    public var fps:int = 30;
    public function Settings() {
        super();
    }
}
}
