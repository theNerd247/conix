pkgs: types: RW: M:

rec
{  
  docs.content.discussion = ''
    TheF ContentF functor encodes constructing a document (markdown, latex,
    etc.) while simutaneously constructing an auxillary data structure. It
    is the sum of the RWF and MarkupF functors.

    The RWF functor encodes adding information to the data context and reading
    from it. Simply put, it is a functor encoding a Reader and Writer monad
    stack.

    The MarkupF functor is just like the core type of Pandoc; it encodes the
    structure of documents that are renderable. Currently MarkupF uses final
    encoding for text documents. However, the plan is to transition into using
    an initial encoding to give API authors more flexibility in interpreting
    Content ASTs.

    `Content` is the recursive type of ContentF; the fixed point of ContentF.
    Authors will use an API that under the hood constructs values of type
    Content. `eval` will then construct the text of that document.
  '';

  # ContentF = RWF + MarkupF
  fmapMatch = f: (RW.fmapMatch f) // (M.fmapMatch f);

  rwMMonoid = _monoid: rec 
    {
      mempty = _: { data = {}; res = _monoid.mempty; };

      memptyWithData = data: _: { inherit data; res = _monoid.mempty; };

      mappend = f: g: x:
        let
          r1 = f x;
          r2 = g x;
        in
          { data = pkgs.lib.attrsets.recursiveUpdate r1.data r2.data;
            res = _monoid.mappend r1.res r2.res;
          };

      mconcat = builtins.foldl' mappend mempty;

      # (Monoid b) => (a -> b) -> [m a] -> m b
      foldMap = f: builtins.foldl' (m: x: mappend m (rwM.fmap f x)) mempty;
    };

  rwM = rec {
    join = f: x: f x x;

    memptyWithText = res: _: { data = {}; inherit res; };

    fmap = f: g: x: 
      let
        r = g x;
      in
        { inherit (r) data; res = f r.res; };

    sequence = 
      (rwMMonoid { mappend = a: b: a ++ b; mempty = []; }).foldMap (x: [x]);
  };

  rwText = rwMMonoid { mappend = a: b: a + b; mempty = ""; };

  docs.content.nill = "ContentF ()";
  nill = types.pure null;

  docs.content.evalAlg.type = ''
    (AttrSet -> { data :: AttrSet, res :: String } ~ t)
    => FreeF b ContentF t -> t
  '';
  evalAlg = types.match
    { 
      "pure" = _: rwText.mempty;
      "text" = rwM.memptyWithText;
      "doc"  = rwText.mconcat;
      "ask"  = rwM.join;
      # NOTE: if we used the Freer encoding then this could be simplified
      # to memptyWithData and the interpretation of bind would take care
      # of the mappend
      "tell" = {_entry, _next}: rwText.mappend _next (rwText.memptyWithData _entry);
    };

  eval = types.cata (types.fmapFree fmapMatch) evalAlg;
}
