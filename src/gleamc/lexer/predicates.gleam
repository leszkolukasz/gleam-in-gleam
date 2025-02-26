import gleam/string

const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

const lowercase = "abcdefghijklmnopqrstuvwxyz"

const alphanum = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

const digits = "0123456789"

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
    Ok(#(c, _rest)) -> c |> string.contains(digits)
    Error(_) -> False
  }
}

pub fn is_string_start(source: String) -> Bool {
  case source |> string.pop_grapheme() {
    Ok(#("\"", _rest)) -> True
    _ -> False
  }
}

// TODO: handle escape sequences
pub fn is_string_continuation(source: String) -> Bool {
  case source |> string.pop_grapheme() {
    Ok(#("\"", _rest)) -> False
    Ok(#(_, _rest)) -> True
    Error(_) -> False
  }
}
