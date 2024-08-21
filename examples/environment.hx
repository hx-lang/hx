//
// The environment monad
//

sig reader(a) {
  ask : () -> a,
}

let env : (a, <reader(a)>b) -> b {
  (v, <ask()>) => resume -> resume(v, v),
  (_, x      )           -> x,
}

let env' : (a, <reader(a)>b) -> b {
  (v, <ask() -> resume>) -> env'(v, resume(v)),
  (_, x                ) -> x
}

let env'' : (a, {[reader(a)]b}) -> b {
  // Closure
  (v, f) -> {
    <ask() => resume> -> resume(v),
  }(f()),
}

let ask_twice : [reader(i64)]i64 {
  ask() + ask()
}

let example : {i64} {
  let x = env(2, ask_twice());
  let y = env'(2, ask_twice());
  let z = env''(2, ask_twice);
  x + y + z
}

let main : i64 = example()