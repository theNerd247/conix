types:

rec
{

  docs.label.tell.type = " { _entry :: AttrSet; _next :: a } -> RWF a";
  tell = types.typed "tell";

  docs.label.ask.type = "(AttrSet -> a) -> RWF a";
  ask = f: 
    if ! builtins.isFunction f 
    then throw "Invalid type: argument to get must be a function"
    else types.typed "ask" f;

  fmapMatch = f: 
    { "tell"  = {_entry, _next}: tell { inherit _entry; _next = f _next; };
      "ask"   = g: ask (x: f (g x));
    };
}
