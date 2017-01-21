package solitaire.commands;
import solitaire.model.*;

class FlipCardCommand implements Command {
    public function new( card: Card ) {
        this.card = card;
    }

    var card: Card;

    public function execute() {
        card.facing = if( card.facing == FaceUp ) FaceDown else FaceUp;
    }

    public function undo() {
        execute();
    }
}