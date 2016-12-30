/**
 * Created by Eoin Landy on 23/12/2016.
 */
package com.tuarua {
import com.tuarua.screenrecorder.constants.LogLevel;
import com.tuarua.screenrecorder.Settings;
import com.tuarua.screenrecorder.events.ScreenRecorderEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;

public class ScreenRecorderANE extends EventDispatcher {
    private static const name:String = "ScreenRecorderANE";
    private var extensionContext:ExtensionContext;
    private var _inited:Boolean = false;

    public var settings:Settings = new Settings();
    private var _savePath:String;
    private var _fileName:String;

    private var _logLevel:int = LogLevel.QUIET;

    public function ScreenRecorderANE() {
        initiate();
    }

    private function initiate():void {
        trace("[" + name + "] Initalizing ANE...");
        try {
            extensionContext = ExtensionContext.createExtensionContext("com.tuarua." + name, null);
            extensionContext.addEventListener(StatusEvent.STATUS, gotEvent);
        } catch (e:Error) {
            trace("[" + name + "] ANE Not loaded properly.  Future calls will fail.");
        }
    }

    private function gotEvent(event:StatusEvent):void {
        var pObj:Object;
        switch (event.level) {
            case "TRACE":
                trace("[" + name + "]", event.code);
                break;
            case "INFO":
                trace("INFO:", event.code);
                break;
            case ScreenRecorderEvent.PERMISSION_GRANTED:
                this.dispatchEvent(new ScreenRecorderEvent(ScreenRecorderEvent.PERMISSION_GRANTED));
                break;
            case ScreenRecorderEvent.PERMISSION_DENIED:
                this.dispatchEvent(new ScreenRecorderEvent(ScreenRecorderEvent.PERMISSION_DENIED));
                break;
            case ScreenRecorderEvent.STARTED:
                this.dispatchEvent(new ScreenRecorderEvent(ScreenRecorderEvent.STARTED));
                break;
            case ScreenRecorderEvent.STOPPED:
                this.dispatchEvent(new ScreenRecorderEvent(ScreenRecorderEvent.STOPPED));
                break;
            case ScreenRecorderEvent.NOT_AVAILABLE:
                this.dispatchEvent(new ScreenRecorderEvent(ScreenRecorderEvent.NOT_AVAILABLE));
                break;
        }
    }

    public function setLogLevel(level:int):void {
        _logLevel = level;
        extensionContext.call("setLogLevel",_logLevel);
    }

    public function isSupported():Boolean {
        return extensionContext.call("isSupported");
    }

    public function initCapture():void {
        extensionContext.call("initCapture");
    }

    public function startCapture():void {
        //ensure filepath and savepath are set
        extensionContext.call("startCapture", settings, _savePath, _fileName);
    }

    public function stopCapture():void {
        extensionContext.call("stopCapture");
    }

    public function set savePath(value:String):void {
        _savePath = value;
    }

    public function set fileName(value:String):void {
        _fileName = value;
    }

    public function dispose():void {
        if (!extensionContext) {
            trace("[" + name + "] Error. ANE Already in a disposed or failed state...");
            return;
        }
        trace("[" + name + "] Unloading ANE...");
        extensionContext.removeEventListener(StatusEvent.STATUS, gotEvent);
        extensionContext.dispose();
        extensionContext = null;
    }


}
}
