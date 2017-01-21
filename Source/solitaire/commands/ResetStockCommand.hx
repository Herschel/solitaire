package solitaire.commands;
import solitaire.model.*;

class ResetStockCommand implements Command {
    public function new( stock: CardPile, waste: CardPile ) {
        this.stock = stock;
        this.waste = waste;
    }

    var stock: CardPile;
    var waste: CardPile;

    public function execute() {
        waste.moveAndFlipTo( stock );
    }

    public function undo() {
        stock.moveAndFlipTo( waste );
    }
}