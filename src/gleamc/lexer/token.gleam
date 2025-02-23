/// Borrowed from [official repo](https://github.com/gleam-lang/gleam/blob/main/compiler-core/src/parse/token.rs)
pub type Token {
  Name(value: String)
  UpName(value: String)
  IntLit(raw_value: String, int_value: Int)
  FloatLit(value: String)
  StringLit(value: String)
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
  EndOfFile
  // Extra
  // unused: CommentNormal
  // unused: CommentModule
  NewLine
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
