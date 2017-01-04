package solitaire;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.*;
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

    var selection(default, set): Array<CardSprite>;
    inline function set_selection( v: Array<CardSprite> ) {
        if( selection != null ) {
            for( cardSprite in selection ) {
                cardSprite.filters = [];
            }
        }

        if( v == null ) {
            v = [];
        }

        selection = v;
        for( cardSprite in v ) {
            cardSprite.filters = [ new openfl.filters.GlowFilter(0xffff00, 1.0, 10, 10, 100) ];
        }

        return v;
    }


    public function new() {
        super();

        stage.frameRate = 60;

        createLog();

        selection = [];

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

            foundationSprite.addEventListener( CardEvent.CLICK, onFoundationClick );

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
        wasteSprite.addEventListener( CardEvent.CLICK, onWasteClick );
        for( i in 0...NUM_PILES ) {
            var pileSprite = pileSprites[i];
            pileSprite.addEventListener( CardEvent.CLICK, onPileClick );
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

    function onWasteClick( _ ) {
        if( waste.numCards > 0 ) {
            selection = [ wasteSprite.peekSprite( 0 ) ];
        }
    }

    function onPileClick( event: CardEvent ) {
        var pileSprite = event.pileSprite;
        var pile = event.pile;

        var card = event.card;

        if( card != null && card.facing == FaceDown ) {
            if( event.cardIndex == 0 && card != null ) {
                card.facing = FaceUp;
            }
            return;
        }

        var selectionPile = null;
        if( selection.length > 0 ) {
            if( selection[0].parent != null && Std.is( selection[0].parent, CardPileSprite ) ) {
                var selectionPileSprite = cast selection[0].parent;
                selectionPile = selectionPileSprite.pile;
            }
        }

        if( selectionPile != pile && selection.length > 0 && areCardsSequential( card, selection[0].card ) ) {
            // Trying to move a sequence of cards onto this card.
            // Check if this card can precede the sequence.

            
            if( selectionPile != null ) {
                for( i in 0...selection.length ) {
                    selectionPile.deal();
                    pile.addCard( selection[i].card );
                }
            }

        } else {

            // Check if clicked card and all following cards are sequential.
            var i = event.cardIndex;
            while( i > 0 ) {
                if( !areCardsSequential( pile.peek( i ), pile.peek( i - 1 ) ) ) {
                    return;
                }
                i--;
            }

            // If they're sequential, then select the entire sequnce of cards.
            var selection = [];
            for( i in 0...event.cardIndex + 1 ) {
                selection.push( pileSprite.peekSprite( event.cardIndex - i ) );
            }
            this.selection = selection;
        }
    }

    function onFoundationClick( event: CardEvent ) {
        var foundation = event.pile;
        var foundationSprite = event.pileSprite;

        var suit = Type.createEnumIndex( CardSuit, foundationSprites.indexOf( foundationSprite ) );

        if( selection.length == 1  && selection[0].card.suit == suit ) {
            var cardSprite = selection[0];
            var card = selection[0].card;
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
                var selectionPile = null;
                if( cardSprite.parent != null && Std.is( cardSprite.parent, CardPileSprite ) ) {
                    var selectionPileSprite = cast cardSprite.parent;
                    selectionPile = selectionPileSprite.pile;
                }
                selectionPile.deal();
                foundation.addCard( card );
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