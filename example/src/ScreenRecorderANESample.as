package {
import com.tuarua.ScreenCaptureANE;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.PermissionEvent;
import flash.filesystem.File;
import flash.permissions.PermissionStatus;

public class ScreenRecorderANESample extends Sprite {
    private var ane:ScreenCaptureANE = new ScreenCaptureANE();

    public function ScreenRecorderANESample() {
        super();
        trace(ane.isSupported());

        //ane.showToast();

        var initBtn:Sprite = createButton(0x33FFCC);
        initBtn.addEventListener(MouseEvent.CLICK, onInit);

        var startBtn:Sprite = createButton(0xCC33CC);
        startBtn.addEventListener(MouseEvent.CLICK, onStart);

        var stopBtn:Sprite = createButton(0x33339A);
        stopBtn.addEventListener(MouseEvent.CLICK, onStop);

        initBtn.x = 50;
        initBtn.y = 50;


        startBtn.x = 200;
        startBtn.y = 50;

        stopBtn.x = 50;
        stopBtn.y = 150;


        addChild(initBtn);
        addChild(startBtn);
        addChild(stopBtn);

        if(File.permissionStatus != PermissionStatus.GRANTED){
            trace("not granted");
            trace("try and create temp file");
            var myFile:File = File.createTempFile();

            trace("myFile.nativePath",myFile.nativePath);
            myFile.addEventListener(PermissionEvent.PERMISSION_STATUS, function (e:PermissionEvent):void {
                if (e.status == PermissionStatus.GRANTED) {
                    trace("granted");

                    trace("file created: ",myFile.exists);

                }else{
                    trace("no stairway granted");
                }
            });

            try {
                myFile.requestPermission();
            } catch (e:Error) {
                trace(e.message);
            }
        }else{
            trace("already granted");
        }

    }

    private function onStart(event:MouseEvent):void {
        ane.startCapture();
    }

    private function onStop(event:MouseEvent):void {
        ane.stopCapture();
    }

    private function onInit(event:MouseEvent):void {
        ane.initCapture();
    }

    private function createButton(clr:uint):Sprite {
        var spr:Sprite = new Sprite();
        spr.graphics.beginFill(clr);
        spr.graphics.drawRect(0, 0, 100, 50);
        spr.graphics.endFill();
        return spr;
    }
}
}