import argv
import clip
import gleam/io
import gleam/list
import gleam/result
import gleamc/cli.{type ParsedCLI}
import gleamc/error.{type GenericError}
import gleamc/lexer
import gleamc/utils
import spinner

pub fn run(parsed_cli: ParsedCLI) -> Result(Nil, GenericError) {
  let spinner_ = spinner.new("Compiling...") |> spinner.start
  use <- utils.defer(fn() { spinner_ |> spinner.stop })

  spinner_ |> spinner.set_text("Phase: lexer")
  list.range(1, 10_000_000)
  use tokens <- result.try(lexer.run(parsed_cli.file))
  io.debug(tokens)

  list.range(1, 10_000_000)
  spinner_ |> spinner.set_text("Phase: parser")
  io.println("Done")
  Ok(Nil)
}

pub fn main() -> Nil {
  let t = #(0, 1)
  io.debug(t.0 - 1)

  let parsing_result =
    cli.new()
    |> clip.run(argv.load().arguments)

  case parsing_result {
    Error(e) -> io.println_error(e)
    Ok(parsed_cli) -> {
      case run(parsed_cli) {
        Error(e) -> e |> error.report
        Ok(_) -> Nil
      }
    }
  }
}
