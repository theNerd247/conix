rec
{
  pkgs = import <nixpkgs> {};
  types = (import ./types.nix) pkgs;
  RW = (import ./readerWriter.nix) pkgs types;
  M = (import ./markdown.nix) types;
  CW = (import ./content.nix) types RW M;

  eval = types.cata 
    (types.fmapFree CW.fmap) 
    (CW.eval RW.collectData M.constructText (_: {}) "");

  run = passed: result: { inherit result; passes = passed result; };

  r = x: CW.tell { _entry = { inherit x; }; _next = types.pure null; };

  t = CW.ask ({x}: r x);

  askTell = run (r: (r.data { x = 2; }) == { x = 2; }) (eval t);
}
