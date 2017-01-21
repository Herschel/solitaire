package solitaire.commands;

class CommandQueue {
    public inline static var COMMAND_HISTORY_SIZE: Int = 16;

    public function new() {
        commandHistory = [];
        currentCommand = 0;
    }

    public function execute( command: Command ) {
        commandHistory.splice( currentCommand, commandHistory.length - currentCommand );
        command.execute();
        commandHistory.push( command );
        currentCommand++;

        if( commandHistory.length > COMMAND_HISTORY_SIZE ) {
            commandHistory.splice( 0, commandHistory.length - COMMAND_HISTORY_SIZE );
            currentCommand = commandHistory.length;
        }
    }

    public function undo() {
        if( currentCommand > 0 ) {
            currentCommand--;
            var command = commandHistory[ currentCommand ];
            if( command != null ) {
                command.undo();
            }
        }
    }

    public function redo() {
        if( currentCommand < commandHistory.length ) {
            var command = commandHistory[ currentCommand ];
            currentCommand++;
            if( command != null ) {
                command.execute();
            }
        }
    }

    var commandHistory: Array<Command>;
    var currentCommand: Int;
}