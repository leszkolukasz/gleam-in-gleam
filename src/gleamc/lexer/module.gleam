import act.{type Action}
import act/state
import gleam/io
import gleam/string
import gleamc/lexer/error.{type LexerError}
import gleamc/lexer/token.{type Token, NewLine}

pub type State {
  State(source: String, index: Int)
}

fn advance(steps: Int) -> Action(Nil, State) {
  use <- state.update(fn(old_state: State) {
    State(
      source: old_state.source |> string.drop_start(steps),
      index: old_state.index + steps,
    )
  })
  act.return(Nil)
}

type LexT(item) =
  Action(Result(item, LexerError), State)

pub fn lex_module() -> LexT(List(Token)) {
  lex_module_tail_rec([])
}

fn lex_module_tail_rec(tokens: List(Token)) -> LexT(List(Token)) {
  use state_: State <- state.get()
  case state_.source {
    "" -> act.return(Ok(tokens))
    _ -> {
      use token <- act.try(lex_definition())
      lex_module_tail_rec([token, ..tokens])
    }
  }
}

fn lex_definition() -> LexT(Token) {
  use state_: State <- state.get()
  io.debug(state_)
  case state_.source {
    "a" <> _rest -> {
      use _ <- act.do(advance(1))
      act.return(Ok(NewLine))
    }
    _ -> panic as "Huh"
  }
}
