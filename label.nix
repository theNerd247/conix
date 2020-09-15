let
  T = import ./types.nix;
in

rec
{

  # LabelF a
  # = Tell AttrSet
  # | Ask (AttrSet -> a)

  docs.label.tell.type = " { _entry :: AttrSet; _next :: a } -> LabelF a";
  tell = T.typed "tell";

  docs.label.ask.type = "(AttrSet -> a) -> LabelF a";
  ask = f: 
    if ! builtins.isFunction f 
    then throw "Invalid type: argument to get must be a function"
    else T.typed "ask" f;

  fmapMatch = f: 
    { "tell"  = {_entry, _next}: tell { inherit _entry; _next = f _next; };
      "ask"   = g: ask (x: f (g x));
    };
}
