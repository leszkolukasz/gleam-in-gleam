import act.{type Action}
import act/state
import gleam/string
import gleamc/lexer/error.{type LexerError}
import gleamc/lexer/token.{type Token, NewLine}
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
    "" -> act.return(Ok(tokens))
    _ -> {
      use new_tokens <- act.try(lex_chunk())
      do_lex_module(utils.concat(new_tokens, tokens))
    }
  }
}

/// Lex the smallest prefix of the source code such that the remaining
/// source code can be unambiguously lexed. This will usually be a single
/// token, but care must be taken to handle cases like:
/// - `a - 2` here `- 2` should be lexed as `[Name(a), Minus, Int(2)]` not `[Name(a), Int(-2)]`
/// - 'a.0.1' here `.0.1` should be lexed as `[Name(a), Dot, Int(0), Dot, Int(1)]` not `[Name(a), Dot, Float(0.1)]`
fn lex_chunk() -> LexT(List(Token)) {
  use state_: State <- state.get()
  case state_.source {
    "a" <> _rest -> consume_and_emit(1, [NewLine])
    _ -> panic as "Huh"
  }
}
