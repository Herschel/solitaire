package solitaire.display;

import openfl.Assets;
import openfl.display.Bitmap;
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
    public static inline var WIDTH = 125 / 1.5;
    public static inline var HEIGHT = 175 / 1.5;

    public static var SUIT_FONT = "fonts/NotoSansSymbols-Regular.ttf";
    public static var RANK_FONT = "fonts/NotoSerif-Regular.ttf";

    public var card(default, null): Card;
    public var image(default, null): Bitmap;

    @:allow( solitaire.display.CardPileSprite )
    public var pileSprite(default, null): Null<CardPileSprite>;
    public var pile(get, never): Null<CardPile>;
    inline function get_pile() {
        if( pileSprite != null ) {
            return pileSprite.pile;
        }

        return null;
    }


    public function new( card: Card ) {
        super();

        if( card == null ) {
            throw "Null card";
        }

        this.card = card;

        /*
        var suit = 0;
        var textColor = switch( card.suit ) {
            case Hearts, Diamonds:  0xffff0000;
            case Spades, Clubs:  0xff000000;
        };

        var text = card.toString();

        textField1 = new TextField();
        textField1.defaultTextFormat = new TextFormat( Assets.getFont( RANK_FONT ).fontName, 20, textColor );
        textField1.embedFonts = true;
        textField1.text = text;
        textField1.setTextFormat( new TextFormat( Assets.getFont( SUIT_FONT ).fontName ), text.length - 1 );
        textField1.selectable = false;
        textField1.x = WIDTH * 0.1;
        textField1.y = HEIGHT * 0.1;
        textField1.mouseEnabled = false;
        textField1.autoSize = openfl.text.TextFieldAutoSize.LEFT;
        addChild( textField1 );

        textField2 = new TextField();
        textField2.defaultTextFormat = new TextFormat( Assets.getFont( RANK_FONT ).fontName, 20, textColor );
        textField2.embedFonts = true;
        textField2.text = text;
        textField2.setTextFormat( new TextFormat( Assets.getFont( SUIT_FONT ).fontName ), text.length - 1 );
        textField2.selectable = false;
        textField2.rotation = 180;
        textField2.x = WIDTH * 0.9;
        textField2.y = HEIGHT * 0.9;
        textField2.mouseEnabled = false;
        textField2.autoSize = openfl.text.TextFieldAutoSize.LEFT;
        addChild( textField2 );*/

        draw();

        card.addEventListener( Event.CHANGE, onCardChange );

        addEventListener( MouseEvent.CLICK, onClick );
        addEventListener( MouseEvent.DOUBLE_CLICK, onDoubleClick );
        addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
        addEventListener( MouseEvent.MOUSE_UP, onMouseUp );

        doubleClickEnabled = true;
    }

    function onCardChange( _ ) {
        draw();
    }

    function draw() {
        if( image != null ) {
            removeChild( image );
        }

        var imageId = if( card.facing == FaceDown ) {
            "art/back.png";
        } else {
            var rankName = switch( card.rank ) {
                case Ace:   "01";
                case Two:   "02";
                case Three: "03";
                case Four:  "04";
                case Five:  "05";
                case Six:   "06";
                case Seven: "07";
                case Eight: "08";
                case Nine:  "09";
                case Ten:   "10";
                case Jack:  "11";
                case Queen: "12";
                case King:  "13";
            };

            var suitName = switch( card.suit ) {
                case Hearts:   "h";
                case Diamonds: "d";
                case Spades:   "s";
                case Clubs:    "c";
            };

             'art/${rankName}${suitName}.png';
         };

        var bitmapData = Assets.getBitmapData( imageId );
        image = new Bitmap( bitmapData, flash.display.PixelSnapping.AUTO, true );
        addChild( image );

        image.scaleX = image.scaleY = Math.min( WIDTH / bitmapData.width, HEIGHT / bitmapData.height );
    }

    function onClick( event ) {
        dispatchEvent( new CardEvent( CardEvent.CLICK, this ) );
    }

    function onDoubleClick( event ) {
        dispatchEvent( new CardEvent( CardEvent.CARD_DOUBLE_CLICK, this ) );
    }

    function onMouseUp( event ) {
        dispatchEvent( new CardEvent( CardEvent.MOUSE_UP, this ) );
    }

    function onMouseDown( event ) {
        dispatchEvent( new CardEvent( CardEvent.MOUSE_DOWN, this ) ); 
    }
}