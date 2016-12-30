/**
 * Created by Eoin Landy on 24/12/2016.
 */
package com.tuarua.screenrecorder.events {
import flash.events.Event;

public class ScreenRecorderEvent extends Event{
    public var params:Object;
    public static const STARTED:String = "ScreenRecorder.Started";
    public static const STOPPED:String = "ScreenRecorder.Stopped";
    public static const PERMISSION_GRANTED:String = "ScreenRecorder.Permission.Granted";
    public static const PERMISSION_DENIED:String = "ScreenRecorder.Permission.Denied";
    public static const NOT_AVAILABLE:String = "ScreenRecorder.NotAvailable";
    public function ScreenRecorderEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
        super(type, bubbles, cancelable);
        this.params = _params;
    }
    public override function clone():Event {
        return new ScreenRecorderEvent(type, this.params, bubbles, cancelable);
    }
    public override function toString():String {
        return formatToString("TorrentAlertEvent", "params", "type", "bubbles", "cancelable");
    }
}
}
