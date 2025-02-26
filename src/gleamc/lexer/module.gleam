import act.{type Action}
import act/state
import gleam/bool
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleamc/lexer/error.{type LexerError}
import gleamc/lexer/predicates
import gleamc/lexer/token.{type Token}
import gleamc/utils

pub type State {
  State(source: String, offset: Int)
}

fn advance(steps: Int) -> Action(Nil, State) {
  use <- state.update(fn(old_state: State) {
    State(
      source: old_state.source |> string.drop_start(steps),
      offset: old_state.offset + steps,
    )
  })
  act.return(Nil)
}

fn consume_and_emit(steps: Int, emit_tokens: List(Token)) -> LexT(List(Token)) {
  use _ <- act.do(advance(steps))
  act.return(Ok(emit_tokens))
}

type LexT(item) =
  Action(Result(item, LexerError), State)

pub fn lex_module() -> LexT(List(Token)) {
  do_lex_module([])
}

fn do_lex_module(tokens: List(Token)) -> LexT(List(Token)) {
  use state_: State <- state.get()
  case state_.source {
    "" -> act.return(Ok(tokens |> list.reverse))
    _ -> {
      use new_tokens <- act.try(lex_chunk())
      do_lex_module(utils.concat(new_tokens, tokens))
    }
  }
}

/// Lex the smallest prefix of the source code such that the remaining
/// source code can be unambiguously lexed. This will usually be a single
/// token, but care must be taken to handle cases like:
/// - 'a.0.1' should be lexed as `[Name(a), Dot, Int(0), Dot, Int(1)]` not `[Name(a), Dot, Float(0.1)]`
fn lex_chunk() -> LexT(List(Token)) {
  use state_: State <- state.get()

  use <- bool.lazy_guard(
    state_.source |> predicates.is_upname_start,
    lex_upname,
  )

  use <- bool.lazy_guard(state_.source |> predicates.is_name_start, lex_name)

  use <- bool.lazy_guard(
    state_.source |> predicates.is_number_start,
    lex_number,
  )

  use <- bool.lazy_guard(
    state_.source |> predicates.is_string_start,
    lex_string,
  )

  case state_.source {
    "(" <> _ -> consume_and_emit(1, [token.LeftParen])
    ")" <> _ -> consume_and_emit(1, [token.RightParen])
    "[" <> _ -> consume_and_emit(1, [token.LeftSquare])
    "]" <> _ -> consume_and_emit(1, [token.RightSquare])
    "{" <> _ -> consume_and_emit(1, [token.LeftBrace])
    "}" <> _ -> consume_and_emit(1, [token.RightBrace])
    "+" <> rest -> {
      case rest {
        "." <> _ -> consume_and_emit(2, [token.PlusDot])
        _ -> consume_and_emit(1, [token.Plus])
      }
    }
    "-" <> rest -> {
      case rest {
        "." <> _ -> consume_and_emit(2, [token.MinusDot])
        ">" <> _ -> consume_and_emit(2, [token.RArrow])
        _ -> consume_and_emit(1, [token.Minus])
      }
    }
    "*" <> rest -> {
      case rest {
        "." <> _ -> consume_and_emit(2, [token.StarDot])
        _ -> consume_and_emit(1, [token.Star])
      }
    }
    "/" <> rest -> {
      case rest {
        "." <> _ -> consume_and_emit(2, [token.SlashDot])
        "/" <> _ -> lex_comment()
        _ -> consume_and_emit(1, [token.Slash])
      }
    }
    "<" <> rest -> {
      case rest {
        ">" <> _ -> consume_and_emit(2, [token.LtGt])
        "<" <> _ -> consume_and_emit(2, [token.LtLt])
        "-" <> _ -> consume_and_emit(2, [token.LArrow])
        "." <> _ -> consume_and_emit(2, [token.LessDot])
        "=" <> rest2 -> {
          case rest2 {
            "." <> _ -> consume_and_emit(3, [token.LessEqualDot])
            _ -> consume_and_emit(2, [token.LessEqual])
          }
        }
        _ -> consume_and_emit(1, [token.Less])
      }
    }
    ">" <> rest -> {
      case rest {
        ">" <> _ -> consume_and_emit(2, [token.GtGt])
        "." <> _ -> consume_and_emit(2, [token.GreaterDot])
        "=" <> rest2 -> {
          case rest2 {
            "." <> _ -> consume_and_emit(3, [token.GreaterEqualDot])
            _ -> consume_and_emit(2, [token.GreaterEqual])
          }
        }
        _ -> consume_and_emit(1, [token.Greater])
      }
    }
    "%" <> _ -> consume_and_emit(1, [token.Percent])
    ":" <> _ -> consume_and_emit(1, [token.Colon])
    "," <> _ -> consume_and_emit(1, [token.Comma])
    "#" <> _ -> consume_and_emit(1, [token.Hash])
    "!" <> rest -> {
      case rest {
        "=" <> _ -> consume_and_emit(2, [token.NotEqual])
        _ -> consume_and_emit(1, [token.Bang])
      }
    }
    "=" <> rest -> {
      case rest {
        "=" <> _ -> consume_and_emit(2, [token.EqualEqual])
        _ -> consume_and_emit(1, [token.Equal])
      }
    }
    "|" <> rest -> {
      case rest {
        "|" <> _ -> consume_and_emit(2, [token.VbarVbar])
        _ -> consume_and_emit(1, [token.Vbar])
      }
    }
    "&" <> rest -> {
      case rest {
        "&" <> _ -> consume_and_emit(2, [token.AmperAmper])
        _ -> panic
      }
    }
    "." <> rest -> {
      case rest {
        "." <> _ -> consume_and_emit(2, [token.DotDot])
        _ -> {
          use _ <- act.do(advance(1))
          use dot_access_tokens <- act.try(maybe_lex_dot_access())
          act.return(Ok([token.Dot, ..dot_access_tokens]))
        }
      }
    }
    "@" <> _ -> consume_and_emit(1, [token.At])
    " " <> _ | "\t" <> _ | "\n" <> _ | "\r" <> _ -> {
      use _ <- act.do(advance(1))
      act.return(Ok([]))
    }
    _ -> panic
  }
}

fn lex_upname() -> LexT(List(Token)) {
  use lexeme <- act.do(take_while("", predicates.is_name_continuation))
  act.return(Ok([token.UpName(lexeme)]))
}

fn lex_name() -> LexT(List(Token)) {
  use lexeme <- act.do(take_while("", predicates.is_name_continuation))
  case token.to_keyword(lexeme) {
    Some(tok) -> act.return(Ok([tok]))
    None -> act.return(Ok([token.Name(lexeme)]))
  }
}

fn lex_number() -> LexT(List(Token)) {
  use lexeme <- act.do(take_while("", predicates.is_number_start))
  // TODO: handle floats
  act.return(Ok([token.Name(lexeme)]))
}

// TODO: add take_while_result version to handle unexpected EOF
fn lex_string() -> LexT(List(Token)) {
  use _ <- act.do(advance(1))
  use lexeme <- act.do(take_while("", predicates.is_string_continuation))

  use state_: State <- state.get()
  let assert Ok(#("\"", _)) = string.pop_grapheme(state_.source)
  use _ <- act.do(advance(1))

  act.return(Ok([token.String(lexeme)]))
}

fn lex_comment() -> LexT(List(Token)) {
  todo
}

fn maybe_lex_dot_access() -> LexT(List(Token)) {
  act.return(Ok([]))
}

fn take_while(
  lexeme: String,
  predicate: fn(String) -> Bool,
) -> Action(String, State) {
  use state_: State <- state.get()

  case state_.source |> predicate {
    True -> {
      case state_.source |> string.pop_grapheme() {
        Ok(#(c, _)) -> {
          use _ <- act.do(advance(1))
          take_while(lexeme <> c, predicate)
        }
        Error(_) -> panic
      }
    }
    False -> act.return(lexeme)
  }
}
