package {

import com.mesmotronic.ane.AndroidFullScreen;
import com.tuarua.ScreenRecorderANE;
import com.tuarua.screenrecorder.constants.LogLevel;
import com.tuarua.screenrecorder.events.ScreenRecorderEvent;

import flash.events.PermissionEvent;
import flash.filesystem.File;
import flash.permissions.PermissionStatus;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.MovieClip;
import starling.display.Quad;
import starling.display.Sprite;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.extensions.lighting.LightSource;
import starling.extensions.lighting.LightStyle;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Align;

import flash.geom.Point;

public class StarlingRoot extends Sprite {

    private var ane:ScreenRecorderANE = new ScreenRecorderANE();
    private var fontSize:int = 36;

    private var initBtn:Sprite;
    private var startBtn:Sprite;
    private var stopBtn:Sprite;

    [Embed(source="../assets/character.png")]
    private static const CharacterTexture:Class;

    [Embed(source="../assets/character_n.png")]
    private static const CharacterNormalTexture:Class;

    [Embed(source="../assets/character.xml", mimeType="application/octet-stream")]
    private static const CharacterXml:Class;

    private var _characters:Vector.<MovieClip>;
    private var _stageWidth:Number;
    private var _stageHeight:Number;

    public function StarlingRoot() {
        super();

    }

    public function start():void {

        if (ane.isSupported()) {
            ane.setLogLevel(LogLevel.DEBUG);
            trace("Is supported ", ane.isSupported());
            ane.settings.width = AndroidFullScreen.fullScreenWidth;
            ane.settings.height = AndroidFullScreen.fullScreenHeight;
            ane.settings.bitrate = 6000000;
            ane.settings.fps = 60;

            ane.fileName = "starling_capture";
            ane.savePath = File.documentsDirectory.nativePath;

            _stageWidth = Starling.current.stage.stageWidth;
            _stageHeight = Starling.current.stage.stageHeight;
            _characters = new <MovieClip>[];

            var characterTexture:Texture = Texture.fromEmbeddedAsset(CharacterTexture);
            var characterNormalTexture:Texture = Texture.fromEmbeddedAsset(CharacterNormalTexture);
            var characterXml:XML = XML(new CharacterXml());

            var textureAtlas:TextureAtlas = new TextureAtlas(characterTexture, characterXml);
            var normalTextureAtlas:TextureAtlas = new TextureAtlas(characterNormalTexture, characterXml);
            var textures:Vector.<Texture> = textureAtlas.getTextures();
            var normalTextures:Vector.<Texture> = normalTextureAtlas.getTextures();

            var ambientLight:LightSource = LightSource.createAmbientLight();
            ambientLight.x = 380;
            ambientLight.y = 60;
            ambientLight.z = -150;
            ambientLight.showLightBulb = false;

            var pointLightA:LightSource = LightSource.createPointLight(0x00ff00);
            pointLightA.x = 180;
            pointLightA.y = 60;
            pointLightA.z = -150;
            pointLightA.showLightBulb = false;

            var pointLightB:LightSource = LightSource.createPointLight(0xff00ff);
            pointLightB.x = 580;
            pointLightB.y = 60;
            pointLightB.z = -150;
            pointLightB.showLightBulb = false;

            var directionalLight:LightSource = LightSource.createDirectionalLight();
            directionalLight.x = 460;
            directionalLight.y = 100;
            directionalLight.z = -150;
            directionalLight.rotationY = -1.0;
            directionalLight.showLightBulb = false;

            addMarchingCharacters(8, textures, normalTextures);
            // addStaticCharacter(textures[0], normalTextures[0]);

            addChild(ambientLight);
            addChild(pointLightA);
            addChild(pointLightB);


            var tfl:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0xFFFFFF);
            tfl.horizontalAlign = Align.LEFT;
            tfl.verticalAlign = Align.TOP;

            var tfr:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0xFFFFFF);
            tfr.horizontalAlign = Align.RIGHT;
            tfr.verticalAlign = Align.TOP;

            initBtn = createButton("Init");
            initBtn.x = (Starling.current.viewPort.width - 320) / 2;
            initBtn.addEventListener(TouchEvent.TOUCH, onInitClicked);
            initBtn.y = 200;
            addChild(initBtn);

            startBtn = createButton("Start");
            startBtn.x = (Starling.current.viewPort.width - 320) / 2;
            startBtn.addEventListener(TouchEvent.TOUCH, onStartClicked);
            startBtn.y = 400;
            startBtn.visible = false;
            addChild(startBtn);

            stopBtn = createButton("Stop");
            stopBtn.x = (Starling.current.viewPort.width - 320) / 2;
            stopBtn.addEventListener(TouchEvent.TOUCH, onStopClicked);
            stopBtn.y = 600;
            stopBtn.visible = false;
            addChild(stopBtn);

            if (File.permissionStatus != PermissionStatus.GRANTED) {
                var myFile:File = File.createTempFile();
                myFile.addEventListener(PermissionEvent.PERMISSION_STATUS, function (e:PermissionEvent):void {
                    if (e.status == PermissionStatus.GRANTED) {
                        if (myFile.exists)
                            myFile.deleteFile();

                        addChild(initBtn);
                        addChild(startBtn);
                        addChild(stopBtn);

                    } else {
                        trace("no stairway, denied");
                    }
                });

                try {
                    myFile.requestPermission();
                } catch (e:Error) {
                    trace(e.message);
                }
            } else {
                trace("already granted");
            }
        } else {
            trace("Only Lollipop and above is supported")
        }


    }

    private function addMarchingCharacters(count:int, textures:Vector.<Texture>,
                                           normalTextures:Vector.<Texture>):void {
        var characterWidth:Number = textures[0].frameWidth;
        var offset:Number = (_stageWidth + characterWidth) / count;

        for (var i:int = 0; i < count; ++i) {
            var movie:MovieClip = createCharacter(textures, normalTextures);
            movie.currentTime = movie.totalTime * Math.random();
            movie.x = -characterWidth + i * offset;
            movie.y = -10;
            movie.addEventListener(Event.ENTER_FRAME, onEnterFrame);
            addChild(movie);
            _characters.push(movie);
        }

        function onEnterFrame(event:Event, passedTime:Number):void {
            var character:MovieClip = event.target as MovieClip;
            character.advanceTime(passedTime);
            character.x += 100 * passedTime;

            if (character.x > _stageWidth)
                character.x = -character.width + (character.x - _stageWidth);
        }
    }

    /** This method is useful during development, to have a simple static image that's easy
     *  to experiment with. */
    private function addStaticCharacter(texture:Texture, normalTexture:Texture):void {
        var movie:MovieClip = createCharacter(
                new <Texture>[texture],
                new <Texture>[normalTexture], 1);

        movie.alignPivot();
        _characters.push(movie);

        var sprite3D:Sprite3D = new Sprite3D();
        sprite3D.addChild(movie);
        sprite3D.x = _stageWidth / 2 + 0.5;
        sprite3D.y = _stageHeight / 2 + 0.5;
        addChild(sprite3D);

        var that:DisplayObject = this;

        sprite3D.addEventListener(TouchEvent.TOUCH, function (event:TouchEvent):void {
            var touch:Touch = event.getTouch(sprite3D, TouchPhase.MOVED);
            if (touch) {
                var movement:Point = touch.getMovement(that);

                if (event.shiftKey) {
                    sprite3D.rotationX -= movement.y * 0.01;
                    sprite3D.rotationY += movement.x * 0.01;
                }
                else {
                    sprite3D.x += movement.x;
                    sprite3D.y += movement.y;
                }
            }
        });
    }


    private function createCharacter(textures:Vector.<Texture>,
                                     normalTextures:Vector.<Texture>,
                                     fps:int = 12):MovieClip {
        var movie:MovieClip = new MovieClip(textures, fps);
        var lightStyle:LightStyle = new LightStyle(normalTextures[0]);
        lightStyle.ambientRatio = 0.3;
        lightStyle.diffuseRatio = 0.7;
        lightStyle.specularRatio = 0.5;
        lightStyle.shininess = 16;
        movie.style = lightStyle;

        for (var i:int = 0; i < movie.numFrames; ++i)
            movie.setFrameAction(i, updateStyle);

        return movie;

        function updateStyle(movieClip:MovieClip, frameID:int):void {
            lightStyle.normalTexture = normalTextures[frameID];
        }
    }

    private function onInitClicked(event:TouchEvent):void {
        var touch:Touch = event.getTouch(initBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            ane.initCapture();
            initBtn.visible = false;
            startBtn.visible = true;
        }
    }


    private function onStartClicked(event:TouchEvent):void {
        var touch:Touch = event.getTouch(startBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            ane.addEventListener(ScreenRecorderEvent.PERMISSION_GRANTED, onRecorderPermissionGranted);
            ane.addEventListener(ScreenRecorderEvent.PERMISSION_DENIED, onRecorderPermissionDenied);
            ane.startCapture();
        }
    }

    private function onRecorderPermissionDenied(event:ScreenRecorderEvent):void {
        trace(event);
    }

    private function onRecorderPermissionGranted(event:ScreenRecorderEvent):void {
        trace(event);
        ane.removeEventListener(ScreenRecorderEvent.PERMISSION_GRANTED, onRecorderPermissionGranted);
        startBtn.visible = false;
        stopBtn.visible = true;
    }

    private function onStopClicked(event:TouchEvent):void {
        var touch:Touch = event.getTouch(stopBtn, TouchPhase.ENDED);
        if (touch && touch.phase == TouchPhase.ENDED) {
            ane.stopCapture();
            stopBtn.visible = false;
            startBtn.visible = true;
        }
    }


    private function createButton(lbl:String):Sprite {
        var spr:Sprite = new Sprite();
        var bg:Quad = new Quad(320, 100, 0xFFFFFF);

        var tf:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0x000000);
        tf.horizontalAlign = Align.CENTER;
        tf.verticalAlign = Align.TOP;

        var lblTxt:TextField = new TextField(320, 80, lbl);
        lblTxt.format = tf;
        lblTxt.y = 32;

        spr.addChild(bg);
        spr.addChild(lblTxt);
        return spr;
    }


}
}