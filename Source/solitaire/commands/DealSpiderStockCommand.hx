package solitaire.commands;
import solitaire.model.*;

class DealSpiderStockCommand implements Command {
    public function new( stock: CardPile, piles: Array<CardPile> ) {
        this.stock = stock;
        this.piles = piles;
    }

    var stock: CardPile;
    var piles: Array<CardPile>;

    public function execute() {
        for( pile in piles ) {
            var card = stock.deal();
            if( card != null ) {
                card.facing = FaceUp;
                pile.addCard( card );
            }
        }
    }

    public function undo() {
        var piles = this.piles.copy();
        piles.reverse();
        for( pile in piles ) {
            var card = pile.deal();
            if( card != null ) {
                card.facing = FaceDown;
                stock.addCard( card );
            }
        }
    }
}