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
let env' : a -> <reader a>b -> b {
  v <ask()> => resume -> resume v v,
  _ x                 -> x,
}

let env'' : (a, <reader a>b) -> b {
  (v, <ask() -> resume>) -> env'(v, resume(v)),
  (_, x                ) -> x
}

let env''' : a -> <reader a>b -> b {
  v <ask() -> resume> -> env''' v resume(v),
  _ x                 -> x
}

let env'''' : (a, {[reader a]b}) -> b {
  // Closure
  (v, {f}) -> {
    <ask() -> resume> -> env''''(v, {resume(v)}),
  }(f()),
}

let ask_twice : [reader i64]i64 {
  ask() + ask()
}

let example : i64 {
  let x = env(2, ask_twice());
  let y = env' 2 ask_twice();
  let z = env''(2, ask_twice());
  let (w : i64) = env'''(2, ask_twice());
  let v = env''''(2, ask_twice);
  x + y + z + w + v
}

let main : i64 = example(); // returns 10

let ask_twice' : [e1:reader i64,e2:reader i64,e3:reader bool]i64 {
  if e3::ask()
  then e1::ask()
  else -e2::ask()
}

let ask_twice'_elab : [e1:reader i64, e2:reader i64, e3:reader bool]i64
  \(e1 : reader i64, e2: reader i64, e3: reader bool)
  { () -> if e3::ask()
          then e1::ask()
          else -e2::ask() }

let ask_twice'' {
  if ask()
  then 1
  else -1
} // inferred: [reader bool]i64

let example2 : i64 = env<e1>(0, env<e2>(42, env<e3>(false, ask_twice'()))); // returns -42

let example2a : i64 =
  let f = env<e3>(false, ask_twice'()); // [e1:reader i64, e2:reader i64]i64
  let g = env<e2>(42, f()); // [e1:reader i64]i64
  ignore (env(0, g()) /* [e1:reader i64]i64 */);
  env<e1>(0, g());
