import clip.{type Command}
import clip/arg
import clip/help

pub opaque type CLI {
  CLI(file: String)
}

pub fn new() -> Command(CLI) {
  clip.command({
    use file <- clip.parameter

    CLI(file)
  })
  |> clip.arg(arg.new("file") |> arg.help("File name"))
  |> clip.help(help.simple("gleamc", "Compile Gleam source file"))
}
