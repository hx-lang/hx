//
// UNIX pipes.
//

sig consumer(a) {
  await : () -> a,
}
sig producer(a) {
  yield : a -> (),
}
sig abort {
  abort(a) : () -> a,
}

use std::collection::list; // equivalent to use std::collection::list as list.
// type rec list(a) {
//   nil,
//   cons(a, list(a)),
// }
use std::option;
// type option(a) {
//   none,
//   some(a),
// }

let pipe : ( <consumer(a)>c, <producer(a)>b ) -> [abort]c {
  (<await()>, <yield(x)>) => resume -> resume(x, ()),
  (x        , <_>       )           -> x,
  (x,       , _         )           -> x,
  (<_>      , _         )           -> abort(),
}

let rec pipe' : ( <consumer(a)>c, <producer(a)>b ) -> [abort]c {
  (<await() -> r>, <yield(x) -> s>) -> pipe'(r(x), s()),
  (x             , <_>            ) -> x,
  (x             , _              ) -> x,
  (<_>           , _              ) -> abort(),
}

rec {
  let pipe'' : ( <consumer(a)>c, {[producer(a)]b} ) -> [abort]c {
    ( <await() -> r>, s ) -> copipe(s(), r),
    ( <await()>     , _ ) -> abort(),
    ( x             , _ ) -> x,
  }

  let copipe : ( <producer(a)>b, {a -> [consumer(a)]c} ) -> [abort]c {
    ( <yield(x) -> s>, r ) -> pipe''(r(x), s),
    ( <yield(_)>     , _ ) -> abort()
    ( _              , _ ) -> abort()
  }
}

let catch : <Abort>a -> Option(a) {
  <abort()> -> None,
  x         -> Some(x),
}

let example : {list(i64)} {
  let rec ones : {[producer(i64)]()} {
    yield(1); ones()
  };
  let add2 : {[consumer(i64)]()} {
    await() + await()
  };
  list.map
    { none -> 0, some(x) -> x }
    cons(catch(pipe(ones(), add2())),
      cons(catch(pipe'(ones(), add2())),
        cons(catch(pipe''(ones(), add2)), nil)))
}

let main : list(i64) = example(); // returns cons(2, cons(2, cons(2, nil)))