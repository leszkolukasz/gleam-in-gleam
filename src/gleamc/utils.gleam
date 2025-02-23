import simplifile

pub fn defer(
  deferred_fn: fn() -> Nil,
  continuation: fn() -> Result(a, b),
) -> Result(a, b) {
  let res = continuation()
  deferred_fn()
  res
}

pub fn read_file(file_name: String) -> String {
  case simplifile.read(from: file_name) {
    Ok(content) -> content
    Error(_) -> panic as "Could not read file"
  }
}
