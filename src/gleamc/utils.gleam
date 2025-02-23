pub fn defer(
  deferred_fn: fn() -> Nil,
  continuation: fn() -> Result(a, b),
) -> Result(a, b) {
  let res = continuation()
  deferred_fn()
  res
}
