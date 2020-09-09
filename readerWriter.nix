{typed, match, ...}:

rec
{
  docs.set.type = " { _entry :: AttrSet; _next :: a } -> StateF a }";
  tell = typed "tell";

  docs.get.type = "(AttrSet -> a) -> StateF a";
  ask = f: 
    if ! builtins.isFunction f 
    then throw "Invalid type: argument to get must be a function"
    else typed "ask" f;

  docs.pure.type = "a -> StateF a";
  pure = x: ask (_: x);

  fmap = f: match
    { "tell"  = x: tell { inherit (x) _entry; _next = (f x._next); };
      "ask"   = g: ask (x: f (g x));
    };
}
