rec
{
  pkgs = import <nixpkgs> {};
  types = (import ./types.nix) pkgs;
  RW = (import ./readerWriter.nix) types;
  M = (import ./markup.nix) types;
  CW = (import ./content.nix) pkgs types RW M;

  eval = types.cata (types.fmapFree CW.fmapMatch) CW.eval;

  run = passed: result: { inherit result; passes = passed result; };

  a = x: RW.tell { _entry = { inherit x; }; _next = types.pure null; };

  b = RW.ask ({x}: a x);

  askTell = run (r: (r { x = 2; }).data == { x = 2; }) (eval t);

  newText = run (r: (r {}).text == "foo") (eval (M.text "foo")); 

  c = RW.ask ({x}: M.text x);

  askText = run (r: r.text == "foo") (eval c);

  s = RW.tell { _entry = { x = "foo"; }; _next = RW.ask(x: M.text ("x = ${x.data.x}")); };

  t = RW.ask(x: RW.tell { _entry = { x = "foo"; }; _next = M.text "x = ${x.data.x}"; } );

  fullEval = x:
      run
      ({data, text}: data == { x = "foo"; } && text == "x = foo")
      (pkgs.lib.fix (eval x));
}
