# GD-Tokenizer

A small godot project with a (very simple) tokenizer written in GDScript.

## Screenshots

![Screenshot showing grep working with piped output](screenshot_2.png)
![Screenshot showing base64 in piped commands](screenshot_1.png)

## Details

This project includes:
- a terminal to input bash like commands
- a very naive and simple tokenizer
- a method to execute the result of the tokenizer

Features:
- string support (double and single quoted)
- bash like commands
- multiple commands in one line (seperator: `;`)
- command piping with `|` (reuse command output as the input for the next command)

What this currently can not do:
- flow control structures like `if`, `for` or `while`
- subshells

The tokenizer is seperated from the execution/parsing. It should be 
relatively easy to implement your own execution method. If you want
to support things like `if`, `for` or `while` you could implement these
in the execution method, there is no need to change the tokenizing method.
You may need to define a few more tokens though.

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

### Minimal Example

```gdscript
extends Node

var parser := CommandParser.new()
var bash_commands := BashLikeCommands.new()

func _ready():
    
    # Define our list of command providers. A command provider is
    # an object with methods for commands. The default method
    # name prefix is "cmd_". Here we want to use the bash like 
    # commands as well as the commands defined in this class.
    command_providers := [self, bash_commands]
    
    # Parse and execute one of the bash like commands: echo
    var result := parser.tokenize("echo 'Hello world!'")
    var stdout := parser.execute(result, command_providers, "%s")
    print(stdout)
    
    # Parse and execute the command 'hello' defined below
    var result := parser.tokenize("hello 'Godot Engine'")
    var stdout := parser.execute(result, command_providers, "%s")
    print(stdout)

func cmd_hello(args: Array, stdin: String):
    if args.size() == 0:
        return "Hello unknown person!"
    elif args.size() == 1:
        return "Hello %s!"
    else:
        return "Error: too many arguments"
```

### Tokenizer and executor method

The most important file is `./cmd/CommandParser.gd`. This is where the tokenization
and execution methods are defined.

To use the class file you need to create a parser object with `var parser := CommandParser.new()`.

It provides two important methods:

#### `CommandParser.tokenize(input)`

Arguments:
- `input`: String

This method will tokenize your input.

Returns: object of type `CommandParser.TokenizedResult`

#### `CommandParser.execute()`

Arguments:
- `tr`: TokenResult
- `providers`: Array of Objects
- `err_tpl`: String (where `%s` represents the error)
- `pre`: String

This method takes a TokenizedResult and tries to execute it. You need to call `execute()`
using a list of command providers and an error template. The template is used to 
format errors, the simplest possible of which is `'%s'` (which simply represents only the error itself).
A command provider can implement commands by defining methods that start with
`cmd_`. This prefix can be changed with an optional parameter. If you want to use
the bash like commands, you can add an instance of `BashLikeCommands` to the command
provider list.

#### `CommandParser.TokenizedResult`

This class is only used to hold data. It is returned by the tokenization method and
can be passed directly into the execution method.

Properties:
- `tokens`: Array (all successfully parsed tokens)
- `consumed`: int (number of characters that were consumed)
- `success`: bool (indicating if everything went well or if there was an error)
- `error`: String (error message if any)
- `remaining`: String (remaining non-tokenized characters if any)

# License

All files (except the fonts in `./fonts/fira-code`) are licensed by the MIT License.
Please see the [License File](LICENSE) for more details.

The font used in the Terminal is named "fira-code". Please see the [License File](fonts/fira-code/OFL.txt) for more details.

# Links to other projects

All links in this section point to amazing external projects.
These are not created by me.

- [Godot Engine](https://godotengine.org/)
- [Fira Code Font](https://github.com/tonsky/FiraCode)

## TODO (Add to this readme later)
- how to define your own tokens
- how to write your own executor (maybe?)

