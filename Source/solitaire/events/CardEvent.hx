package solitaire.events;

import openfl.events.Event;
import solitaire.display.CardSprite;
import solitaire.display.CardPileSprite;
import solitaire.model.Card;
import solitaire.model.CardPile;

class CardEvent extends Event {
    public static inline var ADDED: String = "cardAdded";
    public static inline var REMOVED: String = "cardRemoved";
    public static inline var FLIPPED: String = "cardFlipped";

    public static inline var CLICK: String = "cardClick";
    public static inline var CARD_DOUBLE_CLICK: String = "cardDoubleClick";
    public static inline var PILE_CLICK: String = "cardPileClick";
    public static inline var MOUSE_DOWN: String = "cardMouseDown";
    public static inline var MOUSE_UP: String = "cardMouseUp";

    public static function createPileClickEvent( pileSprite: CardPileSprite ): CardEvent {
        var event = new CardEvent( CardEvent.PILE_CLICK );
        event.pileSprite = pileSprite;
        event.pile = pileSprite.pile;
        return event;
    }

    public static function createFlipEvent( card: Card ): CardEvent {
        var event = new CardEvent( CardEvent.FLIPPED );
        event.card = card;
        event.pile = card.pile;
        return event;
    }

    public static function createAddedEvent( card: Card ): CardEvent {
        var event = new CardEvent( CardEvent.ADDED );
        event.card = card;
        event.pile = card.pile;
        return event;
    }

    public static function createRemovedEvent( card: Card, pile: CardPile ): CardEvent {
        var event = new CardEvent( CardEvent.REMOVED );
        event.card = card;
        event.pile = pile;
        return event;
    }

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
        } else if( cardSprite != null ) {
            this.pileSprite = cardSprite.pileSprite;
            if( this.pileSprite != null ) {
                pile = this.pileSprite.pile;
                cardIndex = pile.indexOf( card );
            }
        }
    }

    public var cardSprite(default, null): Null<CardSprite>;
    public var card(default, null): Null<Card>;
    public var cardIndex: Int;

    public var pileSprite(default, null): Null<CardPileSprite>;
    public var pile(default, null): Null<CardPile>;
}