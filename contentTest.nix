rec
{
  pkgs = import <nixpkgs> {};
  T = import ./types.nix;
  C = import ./content.nix;
  E = import ./eval.nix pkgs;

  CUI = 
    rec
    {
      # Content = Fix ContentF
      markdownFile = _fileName: mkContent: C.ask (x: C.file 
        { _renderType = C.markdown {inherit _fileName; }; 
          _content = mkContent x;
        });

      set = _entry: C.tell { inherit _entry; _next = C.end; };

      # a' -> Content
      liftText = x: if x ? _type then x else C.text x; 
    };

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

  y = C.file
    { _renderType = C.markdown { _fileName = "bar"; };
      _content = [u];
    };

  z = C.file 
    { _renderType = C.dir { _fileName = "baz"; }; 
      _content = [ w y ]; 
    };

  a = CUI.markdownFile "bob" (x: [
    (CUI.liftText "ello ${x.x}")
    (CUI.set { x = "mate"; })
  ]);

}
