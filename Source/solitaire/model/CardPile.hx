package solitaire.model;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import solitaire.events.CardEvent;
import solitaire.games.Game;

class CardPile extends EventDispatcher {
    var cards: Array<Card>;

    public var numCards(get, never): Int;
    inline function get_numCards() { return cards.length; }

    public static function standardDeck( game: Game = null ): CardPile {
        var pile = new CardPile();
        for( rank in Type.allEnums( CardRank ) ) {
            for( suit in Type.allEnums( CardSuit ) ) {
                var card = new Card( rank, suit, FaceDown );
                card.addEventListener( CardEvent.FLIPPED, game.handleCardEvent );
                card.addEventListener( CardEvent.ADDED, game.handleCardEvent );
                card.addEventListener( CardEvent.REMOVED, game.handleCardEvent );
                pile.addCard( card );
            }
        }
        return pile;
    }

    public function new() {
        super();
        cards = [];
    }

    public function addCard( card: Card ) {
        cards.push( card );
        card.pile = this;
        dispatchEvent( new Event( Event.CHANGE ) );
        card.dispatchEvent( CardEvent.createAddedEvent( card ) );
    }

    public function deal(): Null<Card> {
        var card = cards.pop();
        if( card != null ) {
            card.pile = null;
            dispatchEvent( new Event( Event.CHANGE ) );
            card.dispatchEvent( CardEvent.createRemovedEvent( card, this ) );
        }

        return card;
    }

    public function shuffle() {
        var numCards = cards.length;
        for( i in 0...numCards ) {
            var j = Std.int( Math.random() * numCards );
            var temp = cards[i];
            cards[i] = cards[j];
            cards[j] = temp;
        }
    }

    public function moveTo( dst: CardPile ) {
        for( i in 0...numCards ) {
            var card = cards[i];
            card.dispatchEvent( CardEvent.createRemovedEvent( card, this ) );
            dst.addCard( cards[i] );
        }
        cards = [];
        dispatchEvent( new Event( Event.CHANGE ) );
    }

    public function moveAndFlipTo( dst: CardPile ) {
        for( i in 0...numCards ) {
            var card = cards[numCards - i - 1];
            card.dispatchEvent( CardEvent.createRemovedEvent( card, this ) );
            card.facing = if( card.facing == FaceUp ) { FaceDown; } else { FaceUp; };
            dst.addCard( card );
        }
        cards = [];
        dispatchEvent( new Event( Event.CHANGE ) );
    }

    public function peek( i: Int ): Card {
        return cards[numCards - i - 1];
    }

    public function indexOf( card: Card ): Int {
        var i = cards.indexOf( card );
        if( i != -1 ) {
            return numCards - i - 1;
        } else {
            return -1;
        }
    }
}