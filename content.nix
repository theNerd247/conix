pkgs: types: RW: M:

rec
{  
  fmapMatch = f: (RW.fmapMatch f) // (M.fmapMatch f);

  docs.contentWriter.eval.type = ''
    (AttrSet -> { data :: AttrSet, text :: String } ~ t)
    => FreeF b ContentF t -> t
  '';
  eval = types.match
    { "pure" = _: __: { data = {}; text = ""; };
      "text" = t: a: { data = a; text = t; };
      "ask"  = f: x: f x x;
      "tell" = {_entry, _next}: x: 
        let
          res = _next x;
        in
          { data = pkgs.lib.attrsets.recursiveUpdate res.data _entry;
            inherit (res) text;
          };
    };
}
