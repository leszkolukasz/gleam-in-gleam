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
Dot: '.';
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
Name: [a-zA-Z_][a-zA-Z_0-9]* { pushMode(AFTER_NAME); };
UpName: [A-Z][a-zA-Z_0-9]*;

// Literals
Int: [0-9]+ ('_' [0-9]+)*;
Float: Int '.' Int?;
String: '"' (~["] | '\\"')* '"';

// Skip whitespace and comments
WS: [ \t\r]+ -> skip;
COMMENT: '//' ~[\n]* -> skip;

mode AFTER_NAME;
DotAfterName: '.' -> type(Dot), pushMode(AFTER_DOT);
ModeEnd: [^.] -> popMode;

mode AFTER_DOT;
IntAfterDot: [0-9]+ -> type(Int), popMode;
AnotherDot: '.' -> type(Dot), popMode;
ModeExit: [^0-9.] -> popMode;