/*
 * The environment monad.
 */

effect Reader(a) = ask : 1 -> a

sig env : (a, b ! Reader(a)) -> b
let env(v, <ask()>) -> resume = resume(v, v) // deep resumption.
  | env(_, x      )           = x

sig env' : (a, b ! Reader(a)) -> b
let rec env'(v, <ask() -> resume>) = env(v, resume(v)) // shallow resumption
      | env'(_, x                ) = x

sig ex : 1 -> 1 ! Console
let ex() =
  let res = env(2, ask() + ask()) in
  print(string_of_int(res)) // prints 4

let _ = console(ex()) // is console primitive?