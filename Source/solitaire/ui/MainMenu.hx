package solitaire.ui;

import openfl.display.*;
import openfl.events.*;

class MainMenu extends Sprite {
    public function new() {
        super();
        addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
    }

    function onAddedToStage( _ ) {
        var m = new flash.geom.Matrix();
        m.rotate( Math.PI / 2 );
        graphics.beginGradientFill( GradientType.LINEAR, [0x9999ff, 0xeeeeff], [1.0, 1.0], [0, 255], m );
        graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
        graphics.endFill();

        titleLabel = new Label( "Solitaire!!!" );
        titleLabel.fontSize = 40;
        titleLabel.x = (stage.stageWidth - titleLabel.width) * 0.5;
        titleLabel.y = 100;
        addChild( titleLabel );

        klondikeButton = new Button( "Klondike" );
        klondikeButton.x = (stage.stageWidth - klondikeButton.width) * 0.5;
        klondikeButton.y = (stage.stageHeight - klondikeButton.height) * 0.5;
        addChild( klondikeButton );
        klondikeButton.addEventListener( MouseEvent.CLICK, onKlondikeClick );

        spiderButton = new Button( "Spider" );
        spiderButton.x = (stage.stageWidth - spiderButton.width) * 0.5;
        spiderButton.y = (stage.stageHeight - spiderButton.height) * 0.5 + 80;
        addChild( spiderButton );
        spiderButton.addEventListener( MouseEvent.CLICK, onSpiderClick );
    }

    function onKlondikeClick( _ ) { 
        var game = new solitaire.games.Klondike();
        var root = parent;
        root.removeChild( this );
        root.addChild( game );
        game.newGame();
    }

    function onSpiderClick( _ ) { 
        var game = new solitaire.games.Spider();
        var root = parent;
        root.removeChild( this );
        root.addChild( game );
        game.newGame();
    }

    var titleLabel: Label;

    var klondikeButton: Button;
    var spiderButton: Button;
}