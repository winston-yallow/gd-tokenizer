extends Reference
class_name BashLikeCommands
# This file contains some (very badly coded) commands often found on linux.
# Not tested, expect plenty of bugs.


const version := 'v0.0.1-alpha-unstable'


func cmd_base64(args: Array, stdin: String):
    
    var decode: bool
    if args.size() > 0 and args[0] in ['-d', '--decode']:
        args.pop_front()
        decode = true
    else:
        decode = false
    
    if stdin.length() > 0:
        args.append(stdin.lstrip('\n'))
    
    if args.size() == 0:
        return '\n[color=#dd0000]Not enough arguments[/color]'
    elif args.size() == 1:
        if decode:
            return '\n' + Marshalls.base64_to_utf8(args[0])
        else:
            return '\n' + Marshalls.utf8_to_base64(args[0])
    else:
        return '\n[color=#dd0000]Too many arguments[/color]'


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func cmd_free(args: Array, stdin: String):
    var free_template := """
dynamic mem used: %s
static mem used: %s
static mem peak: %s"""
    return free_template % [
        OS.get_dynamic_memory_usage(),
        OS.get_static_memory_usage(),
        OS.get_static_memory_peak_usage()
    ]


func cmd_echo(args: Array, stdin: String):
    return stdin + '\n' + PoolStringArray(args).join(' ')


func cmd_grep(args: Array, stdin: String):
    var stdout := ''
    var highlighting := '[color=#00ff00]$0[/color]'
    
    var regex_str := '(?i)' + PoolStringArray(args).join('|')
    var regex := RegEx.new()
    
    if regex.compile(regex_str) == OK and regex.is_valid():
        for line in stdin.split('\n'):
            var replaced = regex.sub(line, highlighting, true)
            if replaced != line:
                stdout += '\n' + replaced
    else:
        return '\n[color=#dd0000]Regex invalid: %s[/color]' % regex_str
    
    return stdout


# warning-ignore:unused_argument
# warning-ignore:unused_argument
func cmd_info(args: Array, stdin: String):
    return """

    ______            __        __
   / ____/____   ____/ /____   / /_
  / / __ / __ \\ / __  // __ \\ / __/
 / /_/ // /_/ // /_/ // /_/ // /_
 \\____/ \\____/ \\__,_/ \\____/ \\__/
   ______                        _                __
  /_  __/___   _____ ____ ___   (_)____   ____ _ / /
   / /  / _ \\ / ___// __ `__ \\ / // __ \\ / __ `// /
  / /  /  __// /   / / / / / // // / / // /_/ // /
 /_/   \\___//_/   /_/ /_/ /_//_//_/ /_/ \\__,_//_/

- CommandParser: %s
- BashLikeCommands: %s
""" % [CommandParser.version, version]
