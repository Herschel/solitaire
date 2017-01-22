package solitaire.ui;

import openfl.display.*;
import openfl.events.*;
import openfl.geom.ColorTransform;
import openfl.text.*;

class Button extends Sprite {
    public function new( label: String ) {
        super();

        buttonMode = true;

        graphics.beginFill( 0x0000ff );
        graphics.drawRoundRect( 0, 0, 100, 50, 10 );
        graphics.endFill();

        var label = new Label( label );
        label.x = (width - label.width) * 0.5;
        label.y = (height - label.height) * 0.5;
        label.color = 0xffffffff;
        addChild( label );

        addEventListener( MouseEvent.MOUSE_OVER, onMouseOver );
        addEventListener( MouseEvent.MOUSE_OUT, onMouseOut );
    }

    function onMouseOver(_) {
        transform.colorTransform = new ColorTransform( 1.0, 1.0, 1.0, 1.0, 50, 50, 50 );
    }

    function onMouseOut(_) {
        transform.colorTransform = new ColorTransform();
    }
}