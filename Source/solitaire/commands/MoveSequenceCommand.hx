package solitaire.commands;
import solitaire.model.*;

class MoveSequenceCommand implements Command {
    public function new( srcPile: CardPile, srcCards: Array<Card>, dstPile: CardPile ) {
        this.srcPile = srcPile;
        this.srcCards = srcCards;
        this.dstPile = dstPile;
    }

    var srcPile: CardPile;
    var srcCards: Array<Card>;
    var dstPile: CardPile;

    public function execute() {
        for( i in 0...srcCards.length ) {
            srcPile.deal();
            dstPile.addCard( srcCards[i] );
        }
    }

    public function undo() {
        for( i in 0...srcCards.length ) {
            dstPile.deal();
            srcPile.addCard( srcCards[i] );
        }
    }
}