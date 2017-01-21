package solitaire.model;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import solitaire.events.CardEvent;

class Card extends EventDispatcher {
    var value: CardValue;

    @:allow( solitaire.model.CardPile )
    public var pile(default, null): Null<CardPile>;

    public var rank(get, never): CardRank;
    inline function get_rank() { return value.rank; }

    public var suit(get, never): CardSuit;
    inline function get_suit() { return value.suit; }

    public var facing(default, set): CardFacing;
    inline function set_facing(v) {
        facing = v;
        dispatchEvent( new Event(Event.CHANGE) );

        dispatchEvent( CardEvent.createFlipEvent( this ) );
        
        return v;
    }

    public function new( rank: CardRank, suit: CardSuit, facing: CardFacing ) {
        super();

        value = new CardValue( rank, suit );
        this.facing = facing;
    }

    public override function toString(): String {
        return value.toString();
    }
}