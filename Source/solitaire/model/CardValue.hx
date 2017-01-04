package solitaire.model;

class CardValue {
    public var rank: CardRank;
    public var suit: CardSuit;

    public function new( rank: CardRank, suit: CardSuit ) {
        this.rank = rank;
        this.suit = suit;
    }

    public function toString() {
        var rankString = switch( rank ) {
            case Ace:   "A";
            case Two:   "2";
            case Three: "3";
            case Four:  "4";
            case Five:  "5";
            case Six:   "6";
            case Seven: "7";
            case Eight: "8";
            case Nine:  "9";
            case Ten:   "10";
            case Jack:  "J";
            case Queen: "Q";
            case King:  "K";
        };

        var suitString = suitToString( suit );

        return rankString + suitString;
    }

    public static function suitToString( suit: CardSuit ): String {
        return switch( suit ) {
            case Hearts:    "♥";
            case Diamonds:  "♦";
            case Clubs:     "♣";
            case Spades:    "♠";
        };
    }
}