types: RW: M:

rec
{  
  docs.contentWriter.markup.type = "MarkupF a -> ContentF a";
  markup = types.typed "markup";

  docs.contents.readerWriter.type = "RWF a -> ContentF a";
  readerWriter = types.typed "readerWriter";

  docs.contents.fmap.type = "(a -> b) -> ContentF a -> ContentF b";
  fmap = f: types.match
    { "markup"       = x: markup (M.fmap f x);
      "readerWriter" = x: readerWriter (RW.fmap f x);
    };

  docs.contents.text.type = "String -> ContentF a";
  text = t: markup (M.text t);

  docs.contents.ask.type = "(AttrSet -> a) -> ContentF a";
  ask = f: readerWriter (RW.ask f);

  docs.contents.tell.type = "{ _entry :: AttrSet, _next :: a } -> ContentF a";
  tell = x: readerWriter (RW.tell x);

  docs.contentWriter.eval.type = ''
    ({ data :: a, text :: b } ~ t)
    => (RWF a -> a) 
    -> (MarkupF b -> b) 
    -> a
    -> b
    -> FreeF b ContentF t -> t
  '';
  eval = rwAlg: markupAlg: initData: initText: types.match
    { "pure"   = _: { data = initData; text = initText; };
      "markup" = x:
        { data = initData; 
          text = markupAlg (M.fmap (t: t.text) x); 
        };
      "readerWriter" = x: 
        { data = rwAlg (RW.fmap (t: t.data) x); 
          text = initText; 
        };
    };
}
