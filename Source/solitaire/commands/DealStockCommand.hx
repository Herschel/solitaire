package solitaire.commands;
import solitaire.model.*;

class DealStockCommand implements Command {
    public function new( stock: CardPile, waste: CardPile ) {
        this.stock = stock;
        this.waste = waste;
    }

    var stock: CardPile;
    var waste: CardPile;

    public function execute() {
        for( _ in 0...3 ) {
            var card = stock.deal();
            if( card != null ) {
                waste.addCard( card );
                card.facing = FaceUp;
            }
        }
    }

    public function undo() {
        for( _ in 0...3 ) {
            var card = waste.deal();
            if( card != null ) {
                card.facing = FaceDown;
                stock.addCard( card );
            }
        }
    }
}