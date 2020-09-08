let
  pkgs = import <nixpkgs> {};
  types = (import ./types.nix) pkgs;
  rw = (import ./state.nix) types;

  eval = types.cata (types.fmapFree rw.fmap) (types.match
    { "tell" = {tell, _next}: pkgs.lib.attrsets.recursiveUpdate _next tell;
      "ask"  = runGet: runGet { x = 2; };
      "pure" = x: { pure = x; };
    }
  );

  run = expected: result: { inherit result; passes = result == expected; };

in 
  { 
    askTell = with rw; run { x = 2; pure = null;} 
      (eval (ask ({x}: tell { tell = { inherit x; }; _next = types.pure null; })));
  }
