package solitaire;

import openfl.Assets;
import openfl.display.*;
import openfl.events.*;
import openfl.geom.Point;
import openfl.text.*;
import solitaire.commands.*;
import solitaire.display.*;
import solitaire.events.*;
import solitaire.games.*;
import solitaire.model.*;
import solitaire.ui.*;

class Main extends Sprite {
    public function new() {
        super();

        stage.frameRate = 60;
        stage.scaleMode = StageScaleMode.NO_SCALE;

        createLog();

        menu = new MainMenu();
        addChild( menu );
    }

    var menu: MainMenu;

    function createLog() {
        logTextField = new TextField();
        logTextField.width = stage.stageWidth;
        logTextField.height = stage.stageHeight;
        logTextField.selectable = false;
        logTextField.mouseEnabled = false;
        stage.addChild( logTextField );

        haxe.Log.trace = log;
    }

    static function log( t: Dynamic, ?infos: haxe.PosInfos ) {
        if( t != null ) {
            logTextField.appendText( t );
        } else {
            logTextField.appendText( "null" );
        }
        logTextField.appendText( "\n" );
        logTextField.scrollV = logTextField.maxScrollV;
    }

    static var logTextField: TextField;
}
