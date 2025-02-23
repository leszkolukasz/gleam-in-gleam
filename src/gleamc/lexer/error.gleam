import gleam/option.{None, Some}
import gleam/string
import gleamc/error.{type GenericError, GenericError}
import gleamc/types.{type Pos}

pub type LexerError {
  UnexpectedEOF(pos: Pos)
  UnexpectedToken(pos: Pos, actual: Nil, expected: List(Nil))
}

pub fn into_generic(err: LexerError) -> GenericError {
  case err {
    UnexpectedEOF(pos) -> GenericError(pos, "Unexpected end of file", None)
    UnexpectedToken(pos, actual, expected) ->
      GenericError(
        pos,
        "Unexpected token",
        Some(
          "Got: "
          <> actual |> string.inspect
          <> ", expected one of: "
          <> expected |> string.inspect,
        ),
      )
  }
}
