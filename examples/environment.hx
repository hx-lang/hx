//
// The environment monad
//

sig reader a {
  ask : () -> a,
}

let env : (a, <reader a>b) -> b {
  (v, <ask()>) => resume -> resume(v, v),
  (_, x      )           -> x,
}

// Curried
let env : a -> <reader a>b -> b {
  v <ask()> => resume -> resume v v,
  _ x                 -> x,
}

let env' : (a, <reader a>b) -> b {
  (v, <ask() -> resume>) -> env'(v, resume(v)),
  (_, x                ) -> x
}

let env'' : a -> <reader a>b -> b {
  v <ask() -> resume> -> env'' v resume(v),
  _ x                 -> x
}

let env''' : (a, {[reader a]b}) -> b {
  // Closure
  (v, f) -> {
    <ask() => resume> -> resume(v),
  }(f()),
}

let ask_twice : [reader(i64)]i64 {
  ask() + ask()
}

let example : i64 {
  let x = env(2, ask_twice());
  let y = env'(2, ask_twice());
  let z = env'(2, ask_twice());
  let w = env'''(2, ask_twice);
  x + y + z + w
}

let main : i64 = example(); // returns 8

let ask_twice' : [e1:reader i64,e2:reader i64,e3:reader bool]i64 {
  if e3::ask()
  then e1::ask()
  else -e2::ask()
}

let example2 : i64 = env<e1>(0, env<e2>(42, env<e3>(false, ask_twice'))); // returns -42