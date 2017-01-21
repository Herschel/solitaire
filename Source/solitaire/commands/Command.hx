package solitaire.commands;

interface Command {
    function execute(): Void;
    function undo(): Void;
}
