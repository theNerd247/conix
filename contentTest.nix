rec
{
  pkgs = import <nixpkgs> {};
  types = (import ./types.nix) pkgs;
  RW = (import ./readerWriter.nix) types;
  M = (import ./markup.nix) types;
  C = (import ./content.nix) pkgs types RW M;
  CJ = (import ./copyJoin.nix) pkgs;
  FS = (import ./fs.nix) pkgs types C CJ;

  fullEval = eval: x: pkgs.lib.fix (eval x);
  dataEval = eval: x: (fullEval eval x).data;

  s = RW.tell { _entry = { x = "foo"; }; _next = RW.ask(x: M.text ("x = ${x.data.x}")); };

  t = RW.ask(x: RW.tell { _entry = { x = "foo"; }; _next = M.text "x = ${x.data.x}"; } );

  u = RW.tell { _entry = { x = "foo"; }; _next = M.doc
    [ (RW.ask (y: M.text "This is a document ${builtins.toString y.data.y}"))
      (RW.ask (x: M.text "\n with ${x.data.x} content"))
      (RW.tell { _entry = { y = 7; }; _next = C.nill; })
    ];
  };

  v = FS.local ./docs.md;

  v_ = fullEval FS.eval v;

  w = FS.file 
    {
      _fileName = "foo"; 
      _renderType = FS.markdown; 
      _content = M.text "bob"; 
    }; 

  w_ = fullEval FS.eval w;

  y = FS.file
    { _fileName = "bar";
      _renderType = FS.markdown;
      _content = u;
    };

  y_ = fullEval FS.eval y;

  z = FS.dir { _dirName = "z"; _next = [ v w y ]; };

  z_ = fullEval FS.eval z;
}
