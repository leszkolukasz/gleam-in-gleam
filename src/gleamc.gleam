import argv
import clip
import gleam/io
import gleam/list
import gleam/result
import gleamc/cli
import gleamc/error.{type GenericError}
import gleamc/lexer
import gleamc/utils
import spinner

pub fn run(_cli: cli.CLI) -> Result(Nil, GenericError) {
  let indicator = spinner.new("Compiling...") |> spinner.start
  use <- utils.defer(fn() { indicator |> spinner.stop })

  indicator |> spinner.set_text("Phase: lexer")
  list.range(1, 10_000_000)
  use _tokens <- result.try(lexer.run())

  list.range(1, 10_000_000)
  indicator |> spinner.set_text("Phase: parser")

  io.println("Done")
  Ok(Nil)
}

pub fn main() -> Nil {
  let result =
    cli.new()
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(cli) -> {
      case run(cli) {
        Error(e) -> e |> error.report
        Ok(_) -> Nil
      }
    }
  }
}
