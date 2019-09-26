# GD-Tokenizer

A small godot project with a tokenizer written in GDScript.

## Screenshots

![Screenshot showing grep working with piped output](screenshot_2.png)
![Screenshot showing base64 in piped commands](screenshot_1.png)

## Details

This project includes:
- terminal to input bash like commands
- very naive and simple tokenizer
- method to execute the result of the tokenizer

Features:
- string support (double and single quoted)
- bash like commands
- multiple commands in one line (seperator: `;`)
- command piping with `|` (reuse command output as the input for the next command)

What this currently can not do:
- no flow control structures like `if`, `for` or `while`
- no conecpt of subshells

Ther tokenizer is seperated from the execution/parsing. It should be 
relatively easy to implement your own execution method. If you want
to support things like `if`, `for` or `while` you could implement that
in the execution method, there is no need to change the tokenizing method.
You may need to define a few more tokens thought.

## Files

Some important files/directories:
`./cmd`  
`./cmd/BashLikeCommands.gd` _(class that provides a few example bash commands)_  
`./cmd/CommandParser.gd` _(class containing the tokenizer and a method to execute results)_  
`./fonts`  
`./fonts/fira-code` _(directory containing the monospace font I use for the terminal)_  
`./ExampleTerminal.tscn` _(scene with a minimalistic terminal setup)_  
`./ExampleTerminal.gd` _(implements the behaviour of the terminal scene)_  

## Usage

TODO:
- how to use the tokenizer/executor as it is
- how to define your own tokens
- how to write your own executor (maybe?)

