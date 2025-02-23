import gleam/result
import gleamc/error.{type GenericError}
import gleamc/lexer/error.{UnexpectedToken} as lexer_error
import gleamc/types.{Pos}

pub fn run() -> Result(List(Nil), GenericError) {
  {
    use tokens <- result.try(Error(UnexpectedToken(Pos(1, 1), Nil, [Nil, Nil])))
    tokens
  }
  |> result.map_error(lexer_error.into_generic)
}
