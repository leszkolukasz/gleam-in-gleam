lexer grammar GleamLexer;

// Groupings
LeftParen: '(';
RightParen: ')';
LeftSquare: '[';
RightSquare: ']';
LeftBrace: '{';
RightBrace: '}';

// Int Operators
Plus: '+';
Minus: '-';
Star: '*';
Slash: '/';
Less: '<';
Greater: '>';
LessEqual: '<=';
GreaterEqual: '>=';
Percent: '%';

// Float Operators
PlusDot: '+.';
MinusDot: '-.';
StarDot: '*.';
SlashDot: '/.';
LessDot: '<.';
GreaterDot: '>.';
LessEqualDot: '<=.';
GreaterEqualDot: '>=.';

// String Operators
LtGt: '<>';

// Other Punctuation
Colon: ':';
Comma: ',';
Hash: '#';
Bang: '!';
Equal: '=';
EqualEqual: '==';
NotEqual: '!=';
Vbar: '|';
VbarVbar: '||';
AmperAmper: '&&';
LtLt: '<<';
GtGt: '>>';
Pipe: '|>';
Dot: '.' -> mode(AFTER_DOT);
RArrow: '->';
LArrow: '<-';
DotDot: '..';
At: '@';

// Extra
EndOfFile: EOF;
NewLine: '\n';

// Keywords
As: 'as';
Assert: 'assert';
Auto: 'auto';
Case: 'case';
Const: 'const';
Delegate: 'delegate';
Derive: 'derive';
Echo: 'echo';
Fn: 'fn';
Else: 'else';
If: 'if';
Implement: 'implement';
Import: 'import';
Let: 'let';
Macro: 'macro';
Opaque: 'opaque';
Panic: 'panic';
Pub: 'pub';
Test: 'test';
Todo: 'todo';
Type: 'type';
Use: 'use';

// Names
Name: [a-zA-Z_][a-zA-Z_0-9]*;
UpName: [A-Z][a-zA-Z_0-9]*;

// Literals
Int: [0-9]+ ('_' [0-9]+)*;
Float: Int '.' Int?;
String: '"' (~["] | '\\"')* '"';

// Skip whitespace and comments
Whitespace: [ \t\r]+ -> skip;
Comment: '//' ~[\n]* -> skip;

mode AFTER_DOT;
IntAfterDot: Int -> type(Int);
AnotherDot: '.' -> type(Dot);
ModeExit: ~[0-9.] -> mode(DEFAULT_MODE), match; 
//                                          ^
//                                          |
// We dont want this to be a token `ModeExit` but whatever this will be matched to in DEFAULT_MODE.
// ANTLR doesn't seem to have this functionality. One could copy all the rules from DEFAULT_MODE here,
// but that would be too much duplication so I will assume that `match` does exactly what I want.