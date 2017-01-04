package solitaire.display;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import solitaire.model.*;
import solitaire.events.*;

typedef Foo = {
    var a: Int;
    var b: Int;
}

class CardSprite extends Sprite {
    public static inline var WIDTH = 125 / 2.0;
    public static inline var HEIGHT = 175 / 2.0;

    public static inline var FONT = "fonts/arial.ttf";

    public var card(default, null): Card;

    var textField1: TextField;
    var textField2: TextField;

    public function new( card: Card ) {
        super();

        if( card == null ) {
            throw "Null card";
        }

        this.card = card;

        var suit = 0;
        var textColor = switch( card.suit ) {
            case Hearts, Diamonds:  0xffff0000;
            case Spades, Clubs:  0xff000000;
        };

        var text = card.toString();

        textField1 = new TextField();
        textField1.defaultTextFormat = new TextFormat( Assets.getFont(FONT).fontName, 20, textColor );
        textField1.embedFonts = true;
        textField1.text = text;
        textField1.selectable = false;
        textField1.x = WIDTH * 0.1;
        textField1.y = HEIGHT * 0.1;
        textField1.mouseEnabled = false;
        textField1.autoSize = openfl.text.TextFieldAutoSize.LEFT;
        addChild( textField1 );

        textField2 = new TextField();
        textField2.defaultTextFormat = new TextFormat( Assets.getFont(FONT).fontName, 20, textColor );
        textField2.embedFonts = true;
        textField2.text = text;
        textField2.selectable = false;
        textField2.rotation = 180;
        textField2.x = WIDTH * 0.9;
        textField2.y = HEIGHT * 0.9;
        textField2.mouseEnabled = false;
        textField2.autoSize = openfl.text.TextFieldAutoSize.LEFT;
        addChild( textField2 );

        draw();

        card.addEventListener( Event.CHANGE, onCardChange );

        addEventListener( MouseEvent.CLICK, onClick );
    }

    function onCardChange( _ ) {
        draw();
    }

    function draw() {
        graphics.clear();

        if( card != null )
        {
            graphics.lineStyle( 2.0, 0x000000 );
            if( card.facing == FaceUp ) {
                graphics.beginFill( 0xffffff, 1.0 );
            } else {
                graphics.beginFill( 0x3333ff, 1.0 );
            }
            graphics.drawRoundRect( 0, 0, WIDTH, HEIGHT, 10 );
            graphics.endFill();
        }

        textField1.visible = card.facing == FaceUp;
        textField2.visible = card.facing == FaceUp;
    }

    function onClick( event ) {
        dispatchEvent( new CardEvent( CardEvent.CLICK, this ) );
        event.stopImmediatePropagation();
    }
}