package solitaire.display;

import openfl.display.*;
import openfl.events.*;
import solitaire.games.Game;
import solitaire.model.*;

/*
 * Manages to display and animation for cards in a Solitaire game.
 */
class CardTable extends Sprite {
    public function new( game: Game ) {
        super();
        this.game = game;
    }

    var game: Game;
    var cardsToSprites: Map<Card, CardSprite>;

    var pileSprites: CardPileSprite;

    public function addPile( pileSprite: CardPileSprite ) {
        //pileSprites.push( pileSprite );
        addChild( pileSprite );
        //pile.addEventListener()
    }
}
