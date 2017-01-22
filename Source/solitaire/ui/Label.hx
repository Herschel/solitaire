package solitaire.ui;

import flash.display.*;
import openfl.Assets;
import openfl.text.*;

class Label extends Sprite {
    public function new( label: String ) {
        super();
        textField = new TextField();
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.text = label;
        textField.mouseEnabled = false;
        addChild( textField );

        var textFormat = new TextFormat();
        textFormat.font = Assets.getFont( "fonts/NotoSerif-Regular.ttf" ).fontName;
        textField.defaultTextFormat = textFormat;
        textField.setTextFormat( textFormat );
        textField.embedFonts = true;
    }

    public var text(get, set): String;
    function get_text() { return textField.text; }
    function set_text(v) { return textField.text = v; }

    public var fontSize(default, set): Float;
    function set_fontSize(v) {
        fontSize = v;
        var textFormat = new TextFormat();
        textFormat.size = Std.int( v );
        textField.defaultTextFormat = textFormat;
        textField.setTextFormat( textFormat );
        return v;
    }

    public var color(get, set): Int;
    function get_color() { return textField.textColor; }
    function set_color(v) { return textField.textColor = v; }

    var textField: TextField;
}