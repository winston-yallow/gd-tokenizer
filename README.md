# GD-Tokenizer

A small godot project with a tokenizer written in GDScript.

## Screenshots
_TODO_

## Details

This project includes:
- terminal to input bash like commands
- very naive and simple tokenizer
- method to execute the result of the tokenizer

Features:
- string support (double and single quoted)
- bash like commands
- multiple commands in one line (seperator: `;`)
- command pipeing (reuse command output as the input for the next command)

What this currently can not do:
- no flow control structures like `if`, `for` or `while`
- no conecpt of subshells

## Files

- `cmd`
  - `BashLikeCommands.gd` _(class that provides a few example bash commands)_
  - `CommandParser.gd` _(class containing the tokenizer and a method to execute results)_
- `fonts`
  - `fira-code` _(directory containing the monospace font I use for the terminal)_
- `ExampleTerminal.tscn` _(scene with a minimalistic terminal setup)_
- `ExampleTerminal.gd` _(implements the behaviour of the terminal scene)_

