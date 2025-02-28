import gleam/string
import gleamc/lexer/error.{type LexerError, UnexpectedEOF}
import gleamc/types.{type Pos, Pos}

const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

const lowercase = "abcdefghijklmnopqrstuvwxyz"

const alphanum = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

const digits = "0123456789"

// Predicate with accumulator.
pub type ContinuationPredicate(acc) {
  ContinuationPredicate(
    is_continuation: fn(String, acc) -> Result(#(Bool, acc), LexerError),
    default_acc: acc,
  )
}

pub fn is_upname_start(source: String) -> Bool {
  case source |> string.pop_grapheme() {
    Ok(#(c, _rest)) -> uppercase |> string.contains(c)
    Error(_) -> False
  }
}

pub fn is_name_start(source: String) -> Bool {
  case source |> string.pop_grapheme() {
    Ok(#(c, _rest)) -> {
      lowercase |> string.contains(c) || c == "_"
    }
    Error(_) -> False
  }
}

pub fn is_name_continuation(source: String) -> Bool {
  case source |> string.pop_grapheme() {
    Ok(#(c, _rest)) -> {
      alphanum |> string.contains(c) || c == "_"
    }
    Error(_) -> False
  }
}

pub fn is_number_start(source: String) -> Bool {
  case source |> string.pop_grapheme() {
    Ok(#(c, _rest)) -> digits |> string.contains(c)
    Error(_) -> False
  }
}

pub fn is_number_continuation(
  only_int: Bool,
  source: String,
  was_dot: Bool,
) -> Result(#(Bool, Bool), LexerError) {
  case source |> string.pop_grapheme() {
    Ok(#(".", _rest)) if !was_dot -> Ok(#(!only_int, True))
    Ok(#(c, _rest)) -> Ok(#(digits |> string.contains(c), was_dot))
    Error(_) -> Ok(#(False, was_dot))
  }
}

pub fn is_int_continuation(
  source: String,
  was_dot: Bool,
) -> Result(#(Bool, Bool), LexerError) {
  is_number_continuation(True, source, was_dot)
}

pub fn is_float_continuation(
  source: String,
  was_dot: Bool,
) -> Result(#(Bool, Bool), LexerError) {
  is_number_continuation(False, source, was_dot)
}

pub fn is_string_start(source: String) -> Bool {
  case source |> string.pop_grapheme() {
    Ok(#("\"", _rest)) -> True
    _ -> False
  }
}

pub fn is_string_continuation(
  source: String,
  previously_slash: Bool,
) -> Result(#(Bool, Bool), LexerError) {
  case source |> string.pop_grapheme() {
    Ok(#("\"", _rest)) if !previously_slash -> Ok(#(False, False))
    Ok(#("\"", _rest)) if previously_slash -> Ok(#(True, False))
    Ok(#("\\", _rest)) -> Ok(#(True, True))
    Ok(#(_, _rest)) -> Ok(#(True, False))
    Error(_) -> Error(UnexpectedEOF(Pos(0, 0), "string"))
  }
}

// Add fake accumulator for predicate that does not need it.
pub fn extend_with_acc(
  predicate: fn(String) -> Bool,
) -> fn(String, Nil) -> Result(#(Bool, Nil), LexerError) {
  fn(source: String, _acc: Nil) -> Result(#(Bool, Nil), LexerError) {
    case source |> predicate {
      True -> Ok(#(True, Nil))
      False -> Ok(#(False, Nil))
    }
  }
}

pub fn build_predicate_record(
  predicate: fn(String) -> Bool,
) -> ContinuationPredicate(Nil) {
  ContinuationPredicate(extend_with_acc(predicate), Nil)
}

pub const string_predicate = ContinuationPredicate(
  is_string_continuation,
  False,
)

pub const int_predicate = ContinuationPredicate(is_int_continuation, False)

pub const number_predicate = ContinuationPredicate(is_float_continuation, False)
