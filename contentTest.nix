rec
{
  pkgs = import <nixpkgs> {};
  types = (import ./types.nix) pkgs;
  RW = (import ./readerWriter.nix) types;
  M = (import ./markup.nix) types;
  CW = (import ./content.nix) pkgs types RW M;

  eval = types.cata (types.fmapFree CW.fmapMatch) CW.eval;

  run = passed: result: { inherit result; passes = passed result; };

  r = x: RW.tell { _entry = { inherit x; }; _next = types.pure null; };

  t = RW.ask ({x}: r x);

  askTell = run (r: (r { x = 2; }).data == { x = 2; }) (eval t);

  newText = run (r: (r {}).text == "foo") (eval (M.text "foo")); 

  q = RW.ask ({x}: M.text x);

  askText = run (r: r.text == "foo") (eval q);
}
