extends Control


export var prompt_template := '\n[color=#66aaff]godot@terminal:~ [b]$[/b][/color] '
export var input_template := '[color=#ffffff]%s[/color]'
export var error_template := '\n[color=#dd0000][ERROR] %s[/color]'

var parser := CommandParser.new()
var commands := BashLikeCommands.new()

onready var output := $Output as RichTextLabel
onready var input := $Input as LineEdit


func _ready() -> void:
    output_print(prompt_template)
    input.grab_focus()
    input.connect('gui_input', self, 'on_input')


func on_input(event: InputEvent):
    if event is InputEventKey:
        if event.is_action_pressed('cmd_enter'):
            execute_input()

# Implementing this here as the BashLikeCommands should not allow people
# to quit a game that uses those commands.
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func cmd_exit(args: Array, stdin: String):
    get_tree().call_deferred('quit')
    return ''

func execute_input():
    
    # Tokenize and execute the input
    var result := parser.tokenize(input.text)
    var stdout := parser.execute(result, [self, commands], error_template)
    
    # Print everything
    output_print(input_template % input.text)
    output_print(stdout)
    output_print(prompt_template)
    
    # Clear the input
    input.text = ''

func output_print(txt: String):
    output.bbcode_text += txt
