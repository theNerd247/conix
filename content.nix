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

  docs.content.nill = "ContentF ()";
  nill = types.pure null;

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
