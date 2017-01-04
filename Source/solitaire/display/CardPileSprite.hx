package solitaire.display;

import openfl.display.Sprite;
import openfl.events.*;
import solitaire.events.*;
import solitaire.model.*;

class CardPileSprite extends Sprite {
    public var drawBorderWhenEmpty(default, set): Bool;
    inline function set_drawBorderWhenEmpty(v) {
        drawBorderWhenEmpty = v;
        refreshDisplay();
        return v;
    }

    public var pile(default, null): CardPile;

    public var numCards(get, never): Int;
    inline function get_numCards() { return pile.numCards; }

    public var displayStyle(default, set): DisplayStyle;
    inline function set_displayStyle(v) {
        displayStyle = v;
        refreshDisplay();
        return v;
    }

    public var maxCardsToDisplay: Int;

    var cards: Array<CardSprite>;

    public function new( pile: CardPile ) {
        super();

        this.pile = pile;
        pile.addEventListener( Event.CHANGE, function(_) refreshDisplay() );

        displayStyle = Stack;

        addEventListener( MouseEvent.CLICK, onClick );
    }

    public function refreshDisplay() {
        if( cards != null )
        {
            for( card in cards ) {
                removeChild( card );
            }
        }

        graphics.clear();

        cards = [];
        var numCards = pile.numCards;
        if( numCards > 0 )
        {
            if( maxCardsToDisplay > 0 && numCards > maxCardsToDisplay ) {
                numCards = maxCardsToDisplay;
            }

            for( i in 0...numCards ) {
                var card = pile.peek( numCards - i - 1 );
                var cardSprite = new CardSprite( card );

                switch( displayStyle ) {
                    case Stack:
                        cardSprite.x = i * 5;
                        cardSprite.y = i * 5;

                    case HorizontalFan( padding ):
                        cardSprite.x = i * padding;

                    case VerticalFan( padding ):
                        cardSprite.y = i * padding;
                }

                addChild(cardSprite);
                cards.push( cardSprite );
            }
        } else if( drawBorderWhenEmpty ) {
            graphics.lineStyle( 2.0, 0xaaaaaa );
            graphics.beginFill( 0xffffff, 0.0 );
            graphics.drawRoundRect( 0, 0, CardSprite.WIDTH, CardSprite.HEIGHT, 10 );
            graphics.endFill();
        }
    }

    public function peekSprite( i: Int ): Null<CardSprite> {
        return cards[cards.length - i - 1];
    }

    public function peek( i: Int ): Null<Card> {
        return pile.peek( i );
    }

    function onClick( _ ) {
        if( numCards == 0 ) {
            dispatchEvent( new CardEvent( CardEvent.CLICK, null, this ) );
        }
    }
}

enum DisplayStyle {
    Stack;
    HorizontalFan( padding: Float );
    VerticalFan( padding: Float );
}