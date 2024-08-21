//
// Generic counting with effect handlers
//

let count : (((i64) -> bool) -> bool) -> i64 {
  pred ->
    let sig nondet {
      branch : (i64) -> bool
    }; // locally generated signature.
    let hcount : <nondet>bool -> i64 {
      ans                   -> if ans then 1 else 0
      <branch(_) => resume> -> resume(true) + resume(false)
    };
    hcount (pred nondet::branch),
}

let xor : (bool, bool) -> bool {
  (true, false) -> true,
  (false, true) -> true,
  _             -> false,
}

let xor_pred : ((i64) -> bool) -> bool {
  p -> xor(p(0), xor(p(1), xor(p(2), p(3)))),
}

let main : i64 = count xor_pred; // returns 4