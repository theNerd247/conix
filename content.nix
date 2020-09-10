pkgs: types: RW: M:

rec
{  
  # ContentF = RWF + MarkupF
  fmapMatch = f: (RW.fmapMatch f) // (M.fmapMatch f);

  mempty = _: { data = {}; text = ""; };

  memptyWithText = text: _: { data = {}; inherit text; };
  memptyWithData = data: _: { inherit data; text = ""; };

  mappend = f: g: x:
    let
      r1 = f x;
      r2 = g x;
    in
      { data = pkgs.lib.attrsets.recursiveUpdate r1.data r2.data;
        text = r1.text + r2.text;
      };

  mconcat = builtins.foldl' mappend mempty;

  # join :: (a -> (a -> b)) -> a -> b
  join = f: x: f x x;

  docs.content.eval.type = ''
    (AttrSet -> { data :: AttrSet, text :: String } ~ t)
    => FreeF b ContentF t -> t
  '';
  eval = types.match
    { 
      "pure" = _: mempty;
      "text" = memptyWithText;
      "doc"  = mconcat;
      "ask"  = join;
      # NOTE: if we used the Freer encoding then this could be simplified
      # to memptyWithData and the interpretation of bind would take care
      # of the mappend
      "tell" = {_entry, _next}: mappend _next (memptyWithData _entry);
    };
}
