package solitaire.games;

import openfl.Assets;
import openfl.display.*;
import openfl.events.*;
import openfl.geom.Point;
import openfl.text.*;
import solitaire.commands.*;
import solitaire.display.*;
import solitaire.events.*;
import solitaire.model.*;
import solitaire.ui.*;

class Game extends Sprite {
    var cardX: Float;
    var cardY: Float;

    /*
    var victory: Bool;
    var victoryTimer: Int;
    var victorySprites: Array<{card: CardSprite, vx: Float, vy: Float}> = [];
    */

    // Command.
    var commandQueue: CommandQueue;

    // Dragging controls.
    var draggingCards: Array<DragCard>;
    var dragSprite: Sprite;
    var dragX: Float;
    var dragY: Float;

    var table: CardTable;
    var background: Bitmap;

    public function new() {
        super();
        createUi();
        addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
    }

    /* Start a new game of Klondike.
     * Resets all cards.
     */
    public function newGame() {
        commandQueue = new CommandQueue();

        // Play deck shuffling sound.
        var sound = Assets.getSound( "sounds/deck-shuffle.wav" );
        sound.play();
    }

    /* Create New Game button. */
    function createUi() {
        // Make background.
        background = new Bitmap( Assets.getBitmapData( "art/felt_green.jpg" ), PixelSnapping.AUTO, true );
        addChild( background );

        var table = new CardTable( this );
        addChild( table );

        // Make New Game button.
        var button = new Button( "New Game" );
        button.scaleX = button.scaleY = 0.8;
        button.x = 720;
        button.y = 30;
        addChild( button );
        button.addEventListener( MouseEvent.CLICK, function( _ ) newGame() );

        // Make Undo button.
        var button = new Sprite();

        // Draw button art.
        var button = new Button( "Undo" );
        button.scaleX = button.scaleY = 0.8;
        button.x = 720;
        button.y = 80;
        addChild( button );
        button.addEventListener( MouseEvent.CLICK, function( _ ) undo() );

        // Make Redo button.
        var button = new Button( "Redo" );
        button.scaleX = button.scaleY = 0.8;
        button.x = 720;
        button.y = 130;
        addChild( button );
        button.addEventListener( MouseEvent.CLICK, function( _ ) redo() );

        addEventListener( Event.ENTER_FRAME, function( _ ) {
            if( isVictorious() ) {
                trace("YOU WON!!!!");
            }
        } );
    }

    /* Layout the UI when the stage resizes. */
    function onResize( _ ) {
        var gameWidth = CardSprite.WIDTH * 9.5;
        var gameHeight = CardSprite.HEIGHT * 5;
        var scale = Math.min( stage.stageWidth / gameWidth, stage.stageHeight / gameHeight );
        scaleX = scaleY = scale;
        x = Math.max( 0, (stage.stageWidth - gameWidth * scale) * 0.5 );
        background.x = -2 * x;
        var backgroundScale = Math.max(
            background.bitmapData.width / (stage.stageWidth * scale),
            background.bitmapData.height / (stage.stageHeight * scale)
        );
        background.scaleX = background.scaleY = backgroundScale;
    }

    /* Play a randomized card sound. */
    function playCardSound() {
        var cardSound = Std.int( Math.random() * 2 ) + 1;
        var sound = Assets.getSound( 'sounds/deal-card-${cardSound}.wav' );
        sound.play();
    }

    /* Undo the previous user action. */
    function undo() {
        commandQueue.undo();
    }

    /* Redo the previously undone user action. */
    function redo() {
        commandQueue.redo();
    }

    function dragCards( cards: Array<CardSprite> ) {
        dragSprite = new Sprite();
        addChild( dragSprite );

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
            cardPoint = globalToLocal( cardPoint );
            card.x = cardPoint.x;
            card.y = cardPoint.y;
            dragSprite.addChild( card );
        }

        dragX = mouseX;
        dragY = mouseY;

        stage.addEventListener( MouseEvent.MOUSE_MOVE, onDragMove );
        stage.addEventListener( MouseEvent.MOUSE_UP, onDragEnd );
    }

    function onDragMove( event: MouseEvent ) {
        for( card in draggingCards ) {
            card.card.x += mouseX - dragX;
            card.card.y += mouseY - dragY;
        }

        dragX = mouseX;
        dragY = mouseY;
    }

    function onDragEnd( _ ) {
        var topCard = draggingCards[0];
        if( topCard != null ) {
            for( card in draggingCards ) {
                card.initialParent.addChild( card.card );
                card.card.x = card.initialX;
                card.card.y = card.initialY;
            }

            var objects = getObjectsUnderPoint( new Point( stage.mouseX, stage.mouseY ) );
            for( object in objects ) {
                checkCollision( object );
            }
        }

        stage.removeEventListener( MouseEvent.MOUSE_MOVE, onDragMove );
        stage.removeEventListener( MouseEvent.MOUSE_UP, onDragEnd );
    }

    function checkCollision( _ ) { }

    function isVictorious(): Bool {
        return false;
    }

    function onAddedToStage( _ ) {
        stage.addEventListener( Event.RESIZE, onResize );
        onResize( null );
    }

    public function handleCardEvent( event: CardEvent ) {
        
    }
}

// Stores the initial position of dragged cards.
typedef DragCard = {
    initialX: Float,
    initialY: Float,
    initialParent: DisplayObjectContainer,
    parentPile: Null<CardPile>,
    card: CardSprite,
};