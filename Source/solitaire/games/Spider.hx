package solitaire.games;
import openfl.Assets;
import openfl.display.*;
import openfl.events.*;
import openfl.text.*;
import solitaire.commands.*;
import solitaire.display.*;
import solitaire.events.*;
import solitaire.model.*;

/* Spider solitaire. */
class Spider extends Game {
    static inline var NUM_PILES = 10;

    public function new() {
        super();

        pileSprites = [for( i in 0...NUM_PILES ) new CardPileSprite( null ) ];
        for( i in 0...NUM_PILES ) {
            pileSprites[i].x = 20 + i * 110;
            pileSprites[i].y = 10;
            pileSprites[i].drawBorderWhenEmpty = true;
            pileSprites[i].displayStyle = VerticalFan( 30 );
            addChild( pileSprites[i] );
            pileSprites[i].addEventListener( CardEvent.MOUSE_DOWN, onPileMouseDown );
        }

        stockSprite = new CardPileSprite( null );
        stockSprite.x = 600;
        stockSprite.y = 400;
        stockSprite.maxCardsToDisplay = 5;
        stockSprite.displayStyle = Stack;
        stockSprite.drawBorderWhenEmpty = true;
        addChild( stockSprite );

        stockSprite.addEventListener( CardEvent.PILE_CLICK, onStockClick );
    }

    /* Starts a new game of Spider.
     */
    override function newGame() {
        super.newGame();

        var deck = createDeck( 4 );
        deck.shuffle();

        piles = [ for( i in 0...NUM_PILES ) new CardPile() ];
        for( i in 0...NUM_PILES ) {
            pileSprites[i].pile = piles[i];
        }

        var NUM_CARDS = 54;
        var curPile = 0;
        for( _ in 0...NUM_CARDS ) {
            var card = deck.deal();
            piles[curPile].addCard( card );
            if( deck.numCards < 60 ) {
                card.facing = FaceUp;
            }
            curPile++;
            if( curPile >= piles.length ) {
                curPile = 0;
            }
        }

        stock = deck;
        stockSprite.pile = stock;
    }

    /* Creates a Spider deck. */
    function createDeck(numSuits: Int): CardPile {
        var pile = new CardPile();
        var suits: Array<CardSuit> = switch( numSuits ) {
            case 1: [Spades, Spades, Spades, Spades, Spades, Spades, Spades, Spades];
            case 2: [Spades, Hearts, Spades, Hearts, Spades, Hearts, Spades, Hearts];
            case 4: [Spades, Hearts, Clubs, Diamonds, Spades, Hearts, Clubs, Diamonds];
            case _: throw "Invalid number of suits (must be 1, 2, or 4)";
        }

        for( suit in suits ) {
            for( rank in Type.allEnums( CardRank ) ) {
                pile.addCard( new Card( rank, suit, FaceDown ) );
            }
        }
        return pile;
    }

    /* Layout the UI when the stage resizes. */
    override function onResize( _ ) {
        var gameWidth = CardSprite.WIDTH * 14;
        var scale = stage.stageWidth / gameWidth;
        scaleX = scaleY = scale;
    }

    /* Deal a card from the stock to each pile. */
    function onStockClick( _ ) {
        if( stock.numCards > 0 ) {
            commandQueue.execute( new DealSpiderStockCommand( stock, piles ) );
        }
    }

    function onPileMouseDown( event: CardEvent ) {
        var pileSprite = event.pileSprite;
        var pile = event.pile;

        var card = event.card;

        if( card != null && card.facing == FaceDown ) {
            if( event.cardIndex == 0 && card != null ) {
                commandQueue.execute( new FlipCardCommand( card ) );
            }
            return;
        }

        // Check if clicked card and all following cards are sequential.
        var i = event.cardIndex;
        while( i > 0 ) {
            var top = pile.peek( i );
            var bottom = pile.peek( i - 1 );
            if( !areCardsSequential( top, bottom ) || !areCardsSameSuit( top, bottom ) ) {
                return;
            }
            i--;
        }

        // If they're sequential, then select the entire sequnce of cards.
        var draggedCards = [];
        for( i in 0...event.cardIndex + 1 ) {
            draggedCards.push( pileSprite.peekSprite( event.cardIndex - i ) );
        }
        dragCards( draggedCards );
    }

    override function checkCollision( object: DisplayObject ) {
        if( Std.is( object, CardPileSprite ) ) {
            var pileSprite: CardPileSprite = cast object;
            if( pileSprites.indexOf( pileSprite ) != -1 ) {
                onPileEndDrag( pileSprite );
            }
        } else if( Std.is( object, CardSprite ) && Std.is( object.parent, CardPileSprite ) ) {
            var pileSprite: CardPileSprite = cast object.parent;
            if( pileSprites.indexOf( pileSprite ) != -1 ) {
                onPileEndDrag( pileSprite );
            }
        }
    }

    function onPileEndDrag( pileSprite: CardPileSprite ) {
        var cardSprite = draggingCards[0].card;
        var parentPile = draggingCards[0].parentPile;
        var card = cardSprite.card;
        if( cardSprite != null ) {
            if( areCardsSequential( pileSprite.peek( 0 ), card ) ) {
                var srcCard = [for( card in draggingCards ) card.card.card];
                commandQueue.execute( new MoveSequenceCommand( parentPile, srcCard, pileSprite.pile ) );

                checkForFinishedRun( pileSprite.pile );
            }
        }
    }

    /* Checks if there is a completed run at the end of a pile.
     * Removes the completed run from the game.
     */
    function checkForFinishedRun( pile: CardPile ) {
        if( pile.numCards < 13 ) {
            return;
        }

        var i = 12;
        while( i > 0 ) {
            var top = pile.peek( i );
            var bottom = pile.peek( i - 1 );
            if( !areCardsSequential( top, bottom ) || !areCardsSameSuit( top, bottom ) ) {
                return;
            }
            i--;
        }

        // We have a finished run, K-A.
        for( i in 0...13 ) {
            pile.deal();
        }
    }

    function areCardsSequential( top: Card, bottom: Card ): Bool {
        if( top == null ) {
            return true;
        }

        return Type.enumIndex( top.rank ) == Type.enumIndex( bottom.rank ) + 1;
    }

    function areCardsSameSuit( top: Card, bottom: Card ): Bool {
        if( top == null ) {
            return true;
        }

        return top.suit == bottom.suit;
    }

    override function isVictorious(): Bool {
        for( pile in piles ) {
            if( pile.numCards != 0 ) {
                return false;
            }
        }

        return stock.numCards == 0;
    }

    var stock: CardPile;
    var stockSprite: CardPileSprite;

    var piles: Array<CardPile>;
    var pileSprites: Array<CardPileSprite>;
}
