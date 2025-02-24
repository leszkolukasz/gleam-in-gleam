import gleam/list
import simplifile

/// Defer the execution of `deferred_fn` until the end of the current scope.
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

/// Concatenate `lf` and `rt` lists.
/// Complexity: O(length(lf))
pub fn concat(lf: List(item), rt: List(item)) -> List(item) {
  do_concat(lf |> list.reverse, rt)
}

fn do_concat(lf: List(item), rt: List(item)) -> List(item) {
  case lf {
    [] -> rt
    [h, ..tail] -> do_concat(tail, [h, ..rt])
  }
}
