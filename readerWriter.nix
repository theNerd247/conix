types:

rec
{
  docs.readerWriter.set.type = " { _entry :: AttrSet; _next :: a } -> RWF a";
  tell = types.typed "tell";

  docs.readerWriter.get.type = "(AttrSet -> a) -> RWF a";
  ask = f: 
    if ! builtins.isFunction f 
    then throw "Invalid type: argument to get must be a function"
    else types.typed "ask" f;

  docs.pure.type = "a -> RWF a";
  pure = x: ask (_: x);

  fmapMatch = f: 
    { "tell"  = {_entry, _next}: tell { inherit _entry; _next = f _next; };
      "ask"   = g: ask (x: f (g x));
    };
}
