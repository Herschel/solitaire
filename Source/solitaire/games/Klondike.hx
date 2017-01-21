package solitaire.games;
import motion.Actuate;
import openfl.Assets;
import openfl.display.*;
import openfl.events.*;
import openfl.text.*;
import solitaire.commands.*;
import solitaire.display.*;
import solitaire.events.*;
import solitaire.model.*;

/* 
 * Klondike solitaire. 
 * https://en.wikipedia.org/wiki/Klondike_(solitaire)
 */
class Klondike extends Game {
    public function new() {
        super();
        
        pileSprites = [for( i in 0...NUM_PILES ) new CardPileSprite( null ) ];
        for( i in 0...NUM_PILES ) {
            pileSprites[i].x = 20 + i * 110;
            pileSprites[i].y = CardSprite.HEIGHT + 50;
            pileSprites[i].drawBorderWhenEmpty = true;
            pileSprites[i].displayStyle = VerticalFan( 30 );
            addChild( pileSprites[i] );
        }

        stockSprite = new CardPileSprite( null );
        stockSprite.x = 20;
        stockSprite.y = 20;
        stockSprite.maxCardsToDisplay = 5;
        stockSprite.displayStyle = Stack;
        stockSprite.drawBorderWhenEmpty = true;
        addChild( stockSprite );

        wasteSprite = new CardPileSprite( null );
        wasteSprite.x = stockSprite.x + 120;
        wasteSprite.y = 20;
        stockSprite.maxCardsToDisplay = 5;
        wasteSprite.displayStyle = HorizontalFan( 20 );
        wasteSprite.maxCardsToDisplay = 3;
        wasteSprite.drawBorderWhenEmpty = true;
        addChild( wasteSprite );

        foundationSprites = [];
        var numFoundations = Type.allEnums( CardSuit ).length;
        for( i in 0...numFoundations ) {
            var suit = Type.createEnumIndex( CardSuit, i );

            var foundationSprite = new CardPileSprite( null );
            foundationSprite.drawBorderWhenEmpty = true;
            foundationSprite.x = wasteSprite.x + 2.0 * CardSprite.WIDTH + (3 - i) * (CardSprite.WIDTH * 1.25);
            foundationSprite.y = wasteSprite.y;
            foundationSprite.displayStyle = Stack;
            foundationSprite.maxCardsToDisplay = 5;
            addChild( foundationSprite );
            foundationSprites.push( foundationSprite );

            // Add suit icon to foundation art.
            var textColor = switch( suit ) {
                case Hearts, Diamonds:  0xffff0000;
                case Spades, Clubs:  0xff000000;
            };

            var textField = new TextField();
            textField.autoSize = TextFieldAutoSize.CENTER;
            textField.defaultTextFormat = new TextFormat( Assets.getFont( CardSprite.SUIT_FONT ).fontName, 20, textColor );
            textField.embedFonts = true;
            textField.selectable = false;
            textField.mouseEnabled = false;
            textField.text = CardValue.suitToString( suit );
            textField.x = (CardSprite.WIDTH - textField.width) / 2;
            textField.y = (CardSprite.HEIGHT - textField.height) / 2;
            foundationSprite.addChild( textField );
        }

        stockSprite.addEventListener( CardEvent.PILE_CLICK, onStockClick );
        wasteSprite.addEventListener( CardEvent.MOUSE_DOWN, onWasteMouseDown );
        wasteSprite.addEventListener( CardEvent.CARD_DOUBLE_CLICK, onPileDoubleClick );
        for( i in 0...NUM_PILES ) {
            var pileSprite = pileSprites[i];
            pileSprite.addEventListener( CardEvent.MOUSE_DOWN, onPileMouseDown );
            pileSprite.addEventListener( CardEvent.CARD_DOUBLE_CLICK, onPileDoubleClick );
        }
    }

    var stock: CardPile;
    var stockSprite: CardPileSprite;

    var waste: CardPile;
    var wasteSprite: CardPileSprite;

    static inline var NUM_PILES = 7;
    var piles: Array<CardPile>;
    var pileSprites: Array<CardPileSprite>;

    var foundations: Array<CardPile>;
    var foundationSprites: Array<CardPileSprite>;

    /* Starts a new game of Klondike.
     * Resets all cards.
     */
    override function newGame() {
        super.newGame();

        var deck = CardPile.standardDeck( this );
        deck.shuffle();

        piles = [ for( i in 0...NUM_PILES ) new CardPile() ];
        for( i in 0...NUM_PILES ) {
            pileSprites[i].pile = piles[i];

            for( j in i...NUM_PILES ) {
                var card = deck.deal();
                if( i == j ) {
                    card.facing = FaceUp;
                }
                piles[j].addCard( card );
            }
        }

        stock = deck;
        stockSprite.pile = stock;

        waste = new CardPile();
        wasteSprite.pile = waste;

        foundations = [];
        var numFoundations = Type.allEnums( CardSuit ).length;
        for( i in 0...numFoundations ) {
            foundations[i] = new CardPile();
            foundationSprites[i].pile = foundations[i];
        }
    }


    function onStockClick( _ ) {
        if( stock.numCards > 0 ) {
            commandQueue.execute( new DealStockCommand( stock, waste ) );
        } else {
            commandQueue.execute( new ResetStockCommand( stock, waste ) );
        }
    }

    function onWasteMouseDown( event: CardEvent ) {
        if( event.cardIndex == 0 ) {
            dragCards( [event.cardSprite] );
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
            if( !areCardsSequential( pile.peek( i ), pile.peek( i - 1 ) ) ) {
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

    function onPileDoubleClick( event: CardEvent ) {
        var card = event.card;
        if( event.cardIndex == 0 && card != null ) {
            var foundation = foundations[ card.suit.getIndex() ];
            var foundationCard = foundation.peek( 0 );
            var allowMove = if( foundationCard != null ) {
                foundationCard.rank.getIndex() + 1 == card.rank.getIndex();
            } else { card.rank == Ace; };

            if( allowMove ) {
                var command = new MoveSequenceCommand( event.pile, [card], foundation );
                commandQueue.execute( command );
            }
        }
    }

    function onFoundationEndDrag( foundationSprite: CardPileSprite ) {
        var foundation = foundationSprite.pile;

        var suit = Type.createEnumIndex( CardSuit, foundationSprites.indexOf( foundationSprite ) );

        if( draggingCards.length == 1  && draggingCards[0].card.card.suit == suit ) {
            var cardSprite = draggingCards[0].card;
            var card = cardSprite.card;
            var foundationCard = foundation.peek( 0 );
            var allowMove = if( foundationCard != null ) {
                foundationCard.rank.getIndex() + 1 == card.rank.getIndex();
            } else { card.rank == Ace; };

            if( allowMove ) {
                var command = new MoveSequenceCommand( draggingCards[0].parentPile, [draggingCards[0].card.card], foundation );
                commandQueue.execute( command );
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
            }
        }
    }

    override function isVictorious(): Bool {
        for( foundation in foundations ) {
            if( foundation.numCards != 13 ) {
                return false;
            }
        }

        return true;
    }

    function areCardsSequential( top: Card, bottom: Card ): Bool {
        if( top == null ) {
            return bottom.rank == King;
        }

        var isTopRed = top.suit == Hearts || top.suit == Diamonds;
        var isBottomRed = bottom.suit == Hearts || bottom.suit == Diamonds;
        var isOppositeColor = isTopRed != isBottomRed;

        return isOppositeColor && Type.enumIndex( top.rank ) == Type.enumIndex( bottom.rank ) + 1;
    }

    override function checkCollision( object: DisplayObject ) {
        if( Std.is( object, CardPileSprite ) ) {
            var pileSprite: CardPileSprite = cast object;
            if( pileSprites.indexOf( pileSprite ) != -1 ) {
                onPileEndDrag( pileSprite );
            } else if( foundationSprites.indexOf( pileSprite ) != -1 ) {
                onFoundationEndDrag( pileSprite );
            }
        } else if( Std.is( object, CardSprite ) && Std.is( object.parent, CardPileSprite ) ) {
            var pileSprite: CardPileSprite = cast object.parent;
            if( pileSprites.indexOf( pileSprite ) != -1 ) {
                onPileEndDrag( pileSprite );
            } else if( foundationSprites.indexOf( pileSprite ) != -1 ) {
                onFoundationEndDrag( pileSprite );
            }
        }
    }

    public override function handleCardEvent( event: CardEvent ) {
        if( event.type == CardEvent.FLIPPED && event.pile != null ) {
            var pileSprites = pileSprites.concat([stockSprite, wasteSprite]);
            for( pileSprite in pileSprites ) {
                if( pileSprite.pile == event.pile ) {
                    for( i in 0...pileSprite.numCards ) {
                         var cardSprite = pileSprite.peekSprite(i);
                         if( cardSprite != null && cardSprite.card == event.card ) {
                            cardSprite.scaleX = 0;
                            Actuate.tween( cardSprite, 0.4, {scaleX: 1.0} );
                            return;
                        }
                    }
                }
            }
        }
    }

}