extends Reference
class_name CommandParser


const version := 'v1.0.0'

var abc := 'abcdefghijklmnopqrstuvwxyz'
var allowed_chars := abc + abc.to_upper() + '0123456789' + '_-./+~'


class Token:
    # A general Token class. The only information relevant 
    # here is how many characters were consumed. This will
    # be used when tokenizing to proceed to the next position
    # after the token.
    var consumed: int


class TokenError extends Token:
    # Used to tell the tokenizer about an error while parsing.
    var error: String = ''
    func _init(m := '') -> void:
        consumed = 0
        error = m


class TokenString extends Token:
    # Holds a string value. Used by identifiers and strings.
    var value: String
    func _init(c: int, v: String) -> void:
        consumed = c
        value = v


class TokenPipe extends Token:
    # This means that the next command will get the last output as input
    func _init(c: int) -> void:
        consumed = c


class TokenCommandEnd extends Token:
    # This means that the command is finished
    func _init(c: int) -> void:
        consumed = c


class TokenSkip extends Token:
    # Used to tell the tokenizer that this amout of characters can be skipped
    # (chars consumed but no real token found)
    func _init(c: int) -> void:
        consumed = c


class TokenEmpty extends Token:
    # Used to tell the tokenizer that no match was found
    # (nothing consumed and nothing found)
    func _init() -> void:
        consumed = 0


func tokenize_identifier(input: String, current: int) -> Token:
    var consumed := 0
    var value := ''
    while (current + consumed) < len(input) and input[current + consumed] in allowed_chars:
        value += input[current + consumed]
        consumed += 1
    if consumed > 0:
        return TokenString.new(consumed, value)
    else:
        return TokenEmpty.new()


func tokenize_string(input: String, current: int) -> Token:
    var quote_char := input[current] as String
    if quote_char in ["'", '"']:
        var value := ''
        var consumed := 1
        while true:
            if (current + consumed) >= len(input):
                return TokenError.new('unterminated string')
            var c = input[current + consumed]
            consumed += 1
            if c == quote_char:
                return TokenString.new(consumed, value)
            value += c
    return TokenEmpty.new()


func tokenize_skip_whitespace(input: String, current: int) -> Token:
    if input[current] in [' ', '\t']:
        return TokenSkip.new(1)
    return TokenEmpty.new()


func tokenize_pipe(input: String, current: int) -> Token:
    if input[current] == '|':
        return TokenPipe.new(1)
    return TokenEmpty.new()


func tokenize_command_end(input: String, current: int) -> Token:
    if input[current] in [';', '\n']:
        return TokenCommandEnd.new(1)
    return TokenEmpty.new()


class TokenizedResult:
    # Hold the results of a tokenization. These results should always be
    # in one object so that people using this can easily pass this to a
    # parser/execution function. This should decouple the tokenization and
    # execution so that people can freely interchange them with their own
    # implementation.
    
    var tokens: Array
    var consumed: int
    var success: bool
    var error: String
    var remaining: String
    
    func _init(t: Array, c: int, s := true, e := '', r := '') -> void:
        tokens = t
        consumed = c
        success = s
        error = e
        remaining = r


func tokenize(input: String) -> TokenizedResult:
    
    var current := 0  # Index used for iterating the input string
    var tokens := []  # Used to store all detected tokens
    
    # We store references to every known tokenize function. This way
    # we can later loop over them to check if any of these produce
    # a valid result at a specific position in the input string.
    var tokenizers := [
        funcref(self, 'tokenize_pipe'),
        funcref(self, 'tokenize_command_end'),
        funcref(self, 'tokenize_skip_whitespace'),
        funcref(self, 'tokenize_identifier'),
        funcref(self, 'tokenize_string')
    ]
    
    while current < len(input):
        
        # Used to keep track if one of the tokenizers had success
        var success = false
        
        # Try every known tokenizer at the current position
        for fn in tokenizers:
            
            # Try to tokenize the input at the current position. The result is
            # always a Token. Errors are returned as TokenError (extens Token).
            var t := fn.call_func(input, current) as Token
            
            # Return immediately when an error is encountered. The result
            # includes all tokens we already have, the error message, the
            # current position and the remaining text that was not tokenized.
            if t is TokenError:
                return TokenizedResult.new(
                    tokens,
                    current,
                    false,
                    t.error,
                    input.substr(current)
                )
            
            # Skip empty tokens. They are returned when the tokenizer did not
            # find a matching token (this is basically to tell this function to
            # try the next tokenizer)
            elif t is TokenEmpty:
                pass
            
            # Skip the defined number of chars. This is returned for any 
            # whitespace as we only need it to seperate tokens. We do not
            # want to actually have a Token for every whitespace, so we simply
            # skip the defined number of chars and restart our tokenizer loop.
            elif t is TokenSkip:
                success = true
                current += t.consumed
                break
            
            # Every other token should be added to the tokens array
            else:
                success = true
                current += t.consumed
                tokens.append(t)
                break
        
        # No tokenizer was successful so we return an error. We can not proceed
        # as we can not find any token that matches for this position.
        if not success:
            return TokenizedResult.new(
                tokens,
                current,
                false,
                'unrecognized token',
                input.substr(current)
            )
    
    # Add a TokenCommandEnd so that the token list always has an ending
    # This is useful for the executor function. It can simply gather all
    # tokens until it encounters a TokenCommandEnd or a TokenPipe.
    if tokens.size() > 0 and not tokens[-1] is TokenCommandEnd:
        tokens.append(TokenCommandEnd.new(1))
    
    return TokenizedResult.new(tokens, current)

    
func call_cmd(cmd: String, args, stdin: String, providers: Array, pre := '_cmd'):
    var fn_name := pre + cmd.to_lower()
    for provider in providers:
        if provider.has_method(fn_name):
            return provider.call(fn_name, args, stdin)
    return false


func execute(tr: TokenizedResult, providers: Array, err_tpl: String, pre := 'cmd_') -> String:
    
    if not tr.success:
        return err_tpl % ('at char ' + str(tr.consumed) + ': ' + tr.error)
    
    var stdout := ''
    var pipe := false
    var cmd
    var args := []
    
    for t in tr.tokens:
        
        if t is TokenPipe or t is TokenCommandEnd:
            
            var stdin: String
            if pipe:
                stdin = stdout
                stdout = ''
            else:
                stdin = ''
            
            if cmd is String:
                var result = call_cmd(cmd, args, stdin, providers, pre)
                if result is String:
                    stdout += result
                else:
                    return stdout + err_tpl % ('command not found: ' + cmd)
            
            cmd = null
            args.clear()
            pipe = t is TokenPipe
        
        elif 'value' in t:
            
            if not cmd:
                cmd = t.value
            else:
                args.append(t.value)
        
        else:
            print('Unsupported token:', t)
            return stdout + err_tpl % 'unsupported token type detected'
    
    return stdout
