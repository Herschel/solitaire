package solitaire.events;

import openfl.events.Event;
import solitaire.display.CardSprite;
import solitaire.display.CardPileSprite;
import solitaire.model.Card;
import solitaire.model.CardPile;

class CardEvent extends Event {
    public static inline var CLICK: String = "cardClick";
    public static inline var MOUSE_DOWN: String = "cardMouseDown";
    public static inline var MOUSE_UP: String = "cardMouseUp";

    public function new( eventType: String, ?cardSprite: CardSprite, ?pileSprite: CardPileSprite ) {
        super( eventType, true );

        if( cardSprite != null ) {
            this.cardSprite = cardSprite;
            card = cardSprite.card;
        }

        if( pileSprite != null ) {
            this.pileSprite = pileSprite;
            pile = pileSprite.pile;
            cardIndex = pile.indexOf( card );
        } else if( cardSprite != null && cardSprite.parent != null && Std.is( cardSprite.parent, CardPileSprite ) ) {
            this.pileSprite = cast cardSprite.parent;
            pile = this.pileSprite.pile;
            cardIndex = pile.indexOf( card );
        }
    }

    public var cardSprite(default, null): Null<CardSprite>;
    public var card(default, null): Null<Card>;
    public var cardIndex: Int;

    public var pileSprite(default, null): Null<CardPileSprite>;
    public var pile(default, null): Null<CardPile>;
}