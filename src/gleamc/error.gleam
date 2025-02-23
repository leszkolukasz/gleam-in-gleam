import gleam/io
import gleam/option.{type Option}
import gleam/string
import gleamc/types.{type Pos}

pub type GenericError {
  GenericError(pos: Pos, error: String, details: Option(String))
}

pub fn report(err: GenericError) {
  err |> string.inspect |> io.println
}
