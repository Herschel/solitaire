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

    var cardsToSprites: Map<Card, CardSprite>;

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
        var background = new Bitmap( Assets.getBitmapData( "art/felt_green.jpg" ) );
        addChild( background );

        // Make New Game button.
        var button = new Sprite();

        // Draw button art.
        button.graphics.beginFill( 0x0000ff );
        button.graphics.drawRoundRect( 0, 0, 100, 50, 10 );
        button.graphics.endFill();

        var textField = new TextField();
        textField.defaultTextFormat = new TextFormat( Assets.getFont( CardSprite.RANK_FONT ).fontName, 16, 0xffffff );
        textField.text = "New Game";
        textField.embedFonts = true;
        textField.mouseEnabled = false;
        textField.autoSize = TextFieldAutoSize.CENTER;
        textField.x = (button.width - textField.width) * 0.5;
        textField.y = (button.height - textField.height) * 0.5;
        button.addChild( textField );
        button.scaleX = button.scaleY = 0.8;

        button.x = 720;
        button.y = 30;

        button.buttonMode = true;

        addChild( button );

        button.addEventListener( MouseEvent.CLICK, function( _ ) newGame() );

        // Make Undo button.
        var button = new Sprite();

        // Draw button art.
        button.graphics.beginFill( 0x0000ff );
        button.graphics.drawRoundRect( 0, 0, 100, 50, 10 );
        button.graphics.endFill();

        var textField = new TextField();
        textField.defaultTextFormat = new TextFormat( Assets.getFont( CardSprite.RANK_FONT ).fontName, 16, 0xffffff );
        textField.text = "Undo";
        textField.embedFonts = true;
        textField.mouseEnabled = false;
        textField.autoSize = TextFieldAutoSize.CENTER;
        textField.x = (button.width - textField.width) * 0.5;
        textField.y = (button.height - textField.height) * 0.5;
        button.addChild( textField );
        button.scaleX = button.scaleY = 0.8;

        button.x = 720;
        button.y = 80;

        button.buttonMode = true;

        addChild( button );
        button.addEventListener( MouseEvent.CLICK, function( _ ) undo() );

        // Make Redo button.
        var button = new Sprite();

        // Draw button art.
        button.graphics.beginFill( 0x0000ff );
        button.graphics.drawRoundRect( 0, 0, 100, 50, 10 );
        button.graphics.endFill();

        var textField = new TextField();
        textField.defaultTextFormat = new TextFormat( Assets.getFont( CardSprite.RANK_FONT ).fontName, 16, 0xffffff );
        textField.text = "Redo";
        textField.embedFonts = true;
        textField.mouseEnabled = false;
        textField.autoSize = TextFieldAutoSize.CENTER;
        textField.x = (button.width - textField.width) * 0.5;
        textField.y = (button.height - textField.height) * 0.5;
        button.addChild( textField );
        button.scaleX = button.scaleY = 0.8;

        button.x = 720;
        button.y = 130;

        button.buttonMode = true;

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
        var scale = stage.stageWidth / gameWidth;
        scaleX = scaleY = scale;
    }

    /* Play a randomized card sound. */
    function playCardSound() {
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