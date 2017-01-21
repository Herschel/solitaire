package solitaire.commands;

class CompositeCommand {
    public function new() {
        commands = [];
    }

    var commands: Array<Command>;

    public function addCommand( command: Command ) {
        commands.push( command );
    }
    
    public function execute() {
        for( command in commands ) {
            command.execute();
        }
    }

    public function undo() {
        var i = commands.length - 1;
        while( i >= 0 ) {
            commands[i].undo();
            i--;
        }
    }
}
