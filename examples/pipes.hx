/*
 * UNIX pipes.
 */

effect Consumer(a) = await : 1 -> a
effect Producer(a) = yield : a -> 1

effect Abort = abort(a) : 1 -> a

data Option(a) = Some:a
               | None

sig pipe : ( b ! Producer(a), c ! Consumer(a) ) -> c ! Abort
let pipe({prod}, {cons}) =
   let pipe'(<await()>, <yield(x)>) -> resume = resume((), x)
     | pipe'(<_>       , _        )           = abort()
     | pipe'(x         , <_>      )           = x
     | pipe'(x         , _        )           = x
   in pipe'(cons(), prod())

sig pipe' : ( b ! Producer(a), c ! Consumer(a) ) -> c ! Abort
let pipe'({prod}, {cons}) =
   let rec pipe(<await() -> receiver>, <yield(x) -> sender>) = pipe(receiver(x), sender(()))
         | pipe(<_>                  , _                   ) = abort()
         | pipe(x                    , <_>                 ) = x
         | pipe(x,                   , _                   ) = x
   in pipe(cons, prod)

// Recursive groups or `and` bindings?
rec {
  sig pipe1 : ( b ! Producer(a), c ! Consumer(a) ) -> c ! Abort
  let pipe1({prod}, <await() -> receiver>) = copipe(receiver, prod())
    | pipe1({_}   , x                    ) = x

  sig copipe1 : ( a -> c ! Consumer(a), b ! Producer ) -> c ! Abort
  let copipe1({cons}, <yield(x) -> sender>) = pipe({sender(())}, cons(x))
    | copipe1({_}   , _                   ) = abort()
}

sig catch : ( a ! Abort ) -> Option(a)
let catch(<abort()>) = None
  | catch(x)         = Some(x)

sig ex : 1 -> 1 ! Console
let ex =
  let rec ones : 1 ! Producer(Int) = yield(1); ones in
  let add2 : 1 ! Consumer(Int) = await() + await() in
  List.iter
    { None      -> print("None")
    | Some(res) -> print(int_of_string(res)) }
    [ catch(pipe(ones(), add2())), catch(pipe'(ones(), add2())), catch(pipe1(ones(), add2())) ] // prints 222

let _ = console(ex())