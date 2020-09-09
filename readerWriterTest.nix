let
  pkgs = import <nixpkgs> {};
  types = (import ./types.nix) pkgs;
  rw = (import ./readerWriter.nix) types;

  eval = types.cata (types.fmapFree rw.fmap) (types.match
    { "tell" = {_entry, _next}: pkgs.lib.attrsets.recursiveUpdate _next _entry;
      "ask"  = runGet: runGet { x = 2; };
      "pure" = _: {};
    }
  );

  run = expected: result: { inherit result; passes = result == expected; };

in 
  { 
    askTell = with rw; run { x = 2; } 
      (eval (ask ({x}: tell { _entry = { inherit x; }; _next = types.pure null; })));
  }
