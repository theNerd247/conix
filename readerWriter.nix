{typed, match, ...}:

rec
{
  docs.readerWriter.set.type = " { _entry :: AttrSet; _next :: a } -> RWF a";
  tell = typed "tell";

  docs.readerWriter.get.type = "(AttrSet -> a) -> RWF a";
  ask = f: 
    if ! builtins.isFunction f 
    then throw "Invalid type: argument to get must be a function"
    else typed "ask" f;

  docs.pure.type = "a -> RWF a";
  pure = x: ask (_: x);

  docs.readerWriter.fmap = "(a -> b) -> RWF a -> RWF b";
  fmap = f: match
    { "tell"  = x: tell { inherit (x) _entry; _next = (f x._next); };
      "ask"   = g: ask (x: f (g x));
    };

  docs.readerWriter.collectData.type = "RWF (AttrSet -> AttrSet) -> (AttrSet -> AttrSet)";
  collectData = types.match
    { "ask"  = f: x: f x x;
      "tell" = {_entry, _next}: x: pkgs.lib.attrsets.recursiveUpdate (_next x) _entry;
    };
}
