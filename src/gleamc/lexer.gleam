import gleam/pair
import gleam/result
import gleamc/error.{type GenericError}
import gleamc/lexer/error as lexer_error
import gleamc/lexer/module.{State, lex_module}
import gleamc/lexer/token.{type Token}
import gleamc/utils

pub fn run(file_name: String) -> Result(List(Token), GenericError) {
  let source = utils.read_file(file_name)
  let state = State(source, 0)
  lex_module()(state)
  |> pair.second
  |> result.map_error(lexer_error.into_generic)
}
