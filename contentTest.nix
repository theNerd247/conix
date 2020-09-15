rec
{
  pkgs = import <nixpkgs> {};
  T = import ./types.nix;
  C = import ./content.nix;
  E = import ./eval.nix pkgs;

  s = C.tell { _entry = { x = "foo"; }; _next = C.ask(x: C.text ("x = ${x.x}")); };

  t = C.ask(x: C.tell { _entry = { x = "foo"; }; _next = C.text "x = ${x.x}"; } );

  u = C.tell { _entry = { x = "foo"; }; _next = C.file { _renderType = C.noFile; _content =
    [ (C.ask (y: C.text "This is a document ${builtins.toString y.y}"))
      (C.ask (x: C.text "\n with ${x.x} content"))
      (C.tell { _entry = { y = 7; }; _next = C.end; })
    ];
  }; };

  w = C.file 
    {
      _renderType = C.markdown {_fileName = "foo"; }; 
      _content = [(C.text "bob")]; 
    }; 

  # w_ = fullEval C.eval w;

  # y = C.file
  #   { _fileName = "bar";
  #     _renderType = C.markdown;
  #     _content = u;
  #   };

  # y_ = fullEval C.eval y;

  # z = C.dir { _dirName = "z"; _next = [ v w y ]; };

  # z_ = fullEval C.eval z;

  # a = C.file 
  #   { _fileName = "baz";
  #   }
}
