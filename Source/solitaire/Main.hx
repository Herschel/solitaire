package solitaire;

import openfl.Assets;
import openfl.display.*;
import openfl.events.*;
import openfl.geom.Point;
import openfl.text.*;
import solitaire.display.*;
import solitaire.events.*;
import solitaire.model.*;

class Main extends Sprite {
    var cardX: Float;
    var cardY: Float;

    var stock: CardPile;
    var stockSprite: CardPileSprite;

    var waste: CardPile;
    var wasteSprite: CardPileSprite;

    static inline var NUM_PILES = 7;
    var piles: Array<CardPile>;
    var pileSprites: Array<CardPileSprite>;

    var foundations: Array<CardPile>;
    var foundationSprites: Array<CardPileSprite>;

    var victory: Bool;
    var victoryTimer: Int;
    var victorySprites: Array<{card: CardSprite, vx: Float, vy: Float}> = [];

    // Dragging controls.
    var draggingCards: Array<DragCard>;
    var dragSprite: Sprite;
    var dragX: Float;
    var dragY: Float;

    public function new() {
        super();

        stage.frameRate = 60;

        createLog();

        var deck = CardPile.standardDeck();
        deck.shuffle();

        piles = [ for( i in 0...NUM_PILES ) new CardPile() ];
        pileSprites = [for( i in 0...NUM_PILES ) new CardPileSprite( piles[i] ) ];
        for( i in 0...NUM_PILES ) {
            pileSprites[i].x = 20 + i * 110;
            pileSprites[i].y = CardSprite.HEIGHT + 50;
            pileSprites[i].drawBorderWhenEmpty = true;
            pileSprites[i].displayStyle = VerticalFan( 30 );
            addChild( pileSprites[i] );

            for( j in i...NUM_PILES ) {
                var card = deck.deal();
                if( i == j ) {
                    card.facing = FaceUp;
                }
                piles[j].addCard( card );
            }
        }

        stock = deck;
        stockSprite = new CardPileSprite( stock );
        stockSprite.x = 20;
        stockSprite.y = 20;
        stockSprite.maxCardsToDisplay = 5;
        stockSprite.displayStyle = Stack;
        stockSprite.drawBorderWhenEmpty = true;
        addChild( stockSprite );

        waste = new CardPile();
        wasteSprite = new CardPileSprite( waste );
        wasteSprite.x = stockSprite.x + 120;
        wasteSprite.y = 20;
        stockSprite.maxCardsToDisplay = 5;
        wasteSprite.displayStyle = HorizontalFan( 20 );
        wasteSprite.maxCardsToDisplay = 3;
        wasteSprite.drawBorderWhenEmpty = true;
        addChild( wasteSprite );

        var numFoundations = Type.allEnums( CardSuit ).length;
        foundations = [ for( i in 0...numFoundations ) new CardPile() ];
        foundationSprites = [];
        for( i in 0...numFoundations ) {
            var suit = Type.createEnumIndex( CardSuit, i );

            var foundationSprite = new CardPileSprite( foundations[i] );
            foundationSprite.drawBorderWhenEmpty = true;
            foundationSprite.x = wasteSprite.x + 150 + (3 - i) * 80;
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
            textField.defaultTextFormat = new TextFormat( Assets.getFont( CardSprite.FONT ).fontName, 20, textColor );
            textField.embedFonts = true;
            textField.selectable = false;
            textField.mouseEnabled = false;
            textField.text = CardValue.suitToString( suit );
            textField.x = (CardSprite.WIDTH - textField.width) / 2;
            textField.y = (CardSprite.HEIGHT - textField.height) / 2;
            foundationSprite.addChild( textField );
        }

        stockSprite.addEventListener( CardEvent.CLICK, onStockClick );
        wasteSprite.addEventListener( CardEvent.MOUSE_DOWN, onWasteMouseDown );
        for( i in 0...NUM_PILES ) {
            var pileSprite = pileSprites[i];
            pileSprite.addEventListener( CardEvent.MOUSE_DOWN, onPileMouseDown );
        }

        addEventListener( Event.ENTER_FRAME, onEnterFrame );
    }

    function onStockClick( _ ) {
        if( stock.numCards > 0 )
        {
            for( _ in 0...3 ) {
                var card = stock.deal();
                if( card != null ) {
                    card.facing = FaceUp;
                    waste.addCard( card );
                }
            }
        } else {
            waste.moveAndFlipTo( stock );
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
                card.facing = FaceUp;
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

    function onFoundationEndDrag( foundationSprite: CardPileSprite ) {
        var foundation = foundationSprite.pile;

        var suit = Type.createEnumIndex( CardSuit, foundationSprites.indexOf( foundationSprite ) );

        if( draggingCards.length == 1  && draggingCards[0].card.card.suit == suit ) {
            var cardSprite = draggingCards[0].card;
            var card = cardSprite.card;
            var foundationCard = foundation.peek( 0 );
            var allowMove = if( foundationCard != null ) {
                switch( foundationCard.rank ) {
                    case Ace:       card.rank == Two;
                    case Two:       card.rank == Three;
                    case Three:     card.rank == Four;
                    case Four:      card.rank == Five;
                    case Five:      card.rank == Six;
                    case Six:       card.rank == Seven;
                    case Seven:     card.rank == Eight;
                    case Eight:     card.rank == Nine;
                    case Nine:      card.rank == Ten;
                    case Ten:       card.rank == Jack;
                    case Jack:      card.rank == Queen;
                    case Queen:     card.rank == King;
                    case King:      false;
                }
            } else { card.rank == Ace; };

            if( allowMove ) {
                draggingCards[0].parentPile.deal();
                foundation.addCard( card );
            }
        }
    }

    function dragCards( cards: Array<CardSprite> ) {
        dragSprite = new Sprite();
        stage.addChild( dragSprite );

        draggingCards = [];
        for( card in cards ) {
            draggingCards.push({
                initialX: card.x,
                initialY: card.y,
                initialParent: card.parent,
                parentPile: cast( card.parent, CardPileSprite ).pile,
                card: card,
            });
            var cardPoint = new flash.geom.Point( card.x, card.y );
            cardPoint = card.parent.localToGlobal( cardPoint );
            card.x = cardPoint.x;
            card.y = cardPoint.y;
            dragSprite.addChild( card );
        }

        dragX = stage.mouseX;
        dragY = stage.mouseY;

        stage.addEventListener( MouseEvent.MOUSE_MOVE, onDragMove );
        stage.addEventListener( MouseEvent.MOUSE_UP, onDragEnd );
    }

    function onDragMove( event: MouseEvent ) {
        for( card in draggingCards ) {
            card.card.x += stage.mouseX - dragX;
            card.card.y += stage.mouseY - dragY;
        }

        dragX = stage.mouseX;
        dragY = stage.mouseY;
    }

    function onDragEnd( _ ) {
        var topCard = draggingCards[0];
        if( topCard != null ) {
            for( card in draggingCards ) {
                card.initialParent.addChild( card.card );
                card.card.x = card.initialX;
                card.card.y = card.initialY;
            }

            var objects = getObjectsUnderPoint( new Point( mouseX, mouseY ) );
            for( object in objects ) {
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
        }

        stage.removeEventListener( MouseEvent.MOUSE_MOVE, onDragMove );
        stage.removeEventListener( MouseEvent.MOUSE_UP, onDragEnd );
    }

    function onPileEndDrag( pileSprite: CardPileSprite ) {
        var cardSprite = draggingCards[0].card;
        var parentPile = draggingCards[0].parentPile;
        var card = cardSprite.card;
        if( cardSprite != null ) {
            if( areCardsSequential( pileSprite.peek( 0 ), card ) ) {
                for( i in 0...draggingCards.length ) {
                    parentPile.deal();
                    pileSprite.pile.addCard( draggingCards[i].card.card );
                }
            }
        }
    }

    function isVictorious(): Bool {
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

        return isOppositeColor && switch( top.rank ) {
            case Ace:       false;
            case Two:       bottom.rank == Ace;
            case Three:     bottom.rank == Two;
            case Four:      bottom.rank == Three;
            case Five:      bottom.rank == Four;
            case Six:       bottom.rank == Five;
            case Seven:     bottom.rank == Six;
            case Eight:     bottom.rank == Seven;
            case Nine:      bottom.rank == Eight;
            case Ten:       bottom.rank == Nine;
            case Jack:      bottom.rank == Ten;
            case Queen:     bottom.rank == Jack;
            case King:      bottom.rank == Queen;
        }
    }

    function onEnterFrame( _ ) {
        if( isVictorious() ) {
            victory = true;
        }

        if( victory ) {
            victoryTimer++;
            if( victoryTimer == 10 ) {
                var foundation = foundationSprites[Std.int(Math.random() * foundationSprites.length)];

                if( foundation.numCards > 0 ) {
                    var prevCardX = foundation.peekSprite( 0 ).x + foundation.x;
                    var prevCardY = foundation.peekSprite( 0 ).y + foundation.y;
                    var card = foundation.pile.deal();
                    if( card != null ) {
                        var sprite = new CardSprite( card );
                        sprite.x = prevCardX;
                        sprite.y = prevCardY;
                        addChild( sprite );
                        victorySprites.push( {card: sprite, vx: Math.random() * 100 - 50, vy: Math.random() * 200 } );
                    }
                }

                victoryTimer = 0;
            }

            for( card in victorySprites ) {
                card.card.x += card.vx / 60;
                card.card.y += card.vy / 60;
                card.vy += 5;
                card.card.scaleX = card.card.scaleY += 0.001;
            }
        }
    }

    function createLog() {
        logTextField = new TextField();
        logTextField.width = 99999;
        logTextField.height = 99999;
        logTextField.selectable = false;
        logTextField.mouseEnabled = false;
        stage.addChild( logTextField );

        haxe.Log.trace = log;
    }

    static function log( t: Dynamic, ?infos: haxe.PosInfos ) {
        if( t != null ) {
            logTextField.appendText( t );
        } else {
            logTextField.appendText( "null" );
        }
        logTextField.appendText( "\n" );
    }

    static var logTextField: TextField;
}

// Stores the initial position of dragged cards.
typedef DragCard = {
    initialX: Float,
    initialY: Float,
    initialParent: DisplayObjectContainer,
    parentPile: Null<CardPile>,
    card: CardSprite,
};