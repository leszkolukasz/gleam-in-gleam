import gleam/option.{type Option, None, Some}

/// Borrowed from [official repo](https://github.com/gleam-lang/gleam/blob/main/compiler-core/src/parse/token.rs)
pub type Token {
  Name(value: String)
  UpName(value: String)
  Int(raw_value: String, int_value: Int)
  Float(value: String)
  String(value: String)
  // unused: CommentDoc(value: String)
  // Groupings
  LeftParen
  RightParen
  LeftSquare
  RightSquare
  LeftBrace
  RightBrace
  // Int Operators
  Plus
  Minus
  Star
  Slash
  Less
  Greater
  LessEqual
  GreaterEqual
  Percent
  // Float Operators
  PlusDot
  MinusDot
  StarDot
  SlashDot
  LessDot
  GreaterDot
  LessEqualDot
  GreaterEqualDot
  // String Operators
  LtGt
  // Other Punctuation
  Colon
  Comma
  Hash
  Bang
  Equal
  EqualEqual
  NotEqual
  Vbar
  VbarVbar
  AmperAmper
  LtLt
  GtGt
  Pipe
  Dot
  RArrow
  LArrow
  DotDot
  At
  // unused: EndOfFile
  // Extra
  // unused: CommentNormal
  // unused: CommentModule
  // unused: NewLine
  // Keywords:
  As
  Assert
  Auto
  Case
  Const
  Delegate
  Derive
  Echo
  Else
  Fn
  If
  Implement
  Import
  Let
  Macro
  Opaque
  Panic
  Pub
  Test
  Todo
  Type
  Use
}

pub fn to_keyword(lexeme: String) -> Option(Token) {
  case lexeme {
    "as" -> Some(As)
    "assert" -> Some(Assert)
    "auto" -> Some(Auto)
    "case" -> Some(Case)
    "const" -> Some(Const)
    "delegate" -> Some(Delegate)
    "derive" -> Some(Derive)
    "echo" -> Some(Echo)
    "else" -> Some(Else)
    "fn" -> Some(Fn)
    "if" -> Some(If)
    "implement" -> Some(Implement)
    "import" -> Some(Import)
    "let" -> Some(Let)
    "macro" -> Some(Macro)
    "opaque" -> Some(Opaque)
    "panic" -> Some(Panic)
    "pub" -> Some(Pub)
    "test" -> Some(Test)
    "todo" -> Some(Todo)
    "type" -> Some(Type)
    "use" -> Some(Use)
    _ -> None
  }
}
