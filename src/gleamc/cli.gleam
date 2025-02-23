import clip.{type Command}
import clip/arg
import clip/help

pub type ParsedCLI {
  Compile(file: String)
}

pub fn new() -> Command(ParsedCLI) {
  clip.command({
    use file <- clip.parameter

    Compile(file)
  })
  |> clip.arg(arg.new("file") |> arg.help("File name"))
  |> clip.help(help.simple("gleamc", "Compile Gleam source file"))
}
