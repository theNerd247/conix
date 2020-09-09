pkgs: types: RW: M:

rec
{  
  docs.contentWriter.markup.type = "MarkupF a -> ContentF a";
  markup = types.typed "markup";

  docs.contents.readerWriter.type = "RWF a -> ContentF a";
  readerWriter = types.typed "readerWriter";

  docs.contentWriter.fmap.type = "(a -> b) -> ContentF a -> ContentF b";
  fmap = f: types.match
    { "markup"       = x: markup (M.fmap f x);
      "readerWriter" = x: readerWriter (RW.fmap f x);
    };

  docs.contentWriter.eval.type = ''
    ({ data :: a, text :: b } ~ t)
    => (RWF a -> a) 
    -> (MarkupF b -> b) 
    -> a
    -> b
    -> FreeF b ContentF t -> t
  '';
  eval = rwAlg: markupAlg: initData: initText: types.match
    { "pure"   = _: __: { data = initData; text = initText; };
      "markup" = x: 
        { data = initData; 
          text = markupAlg (M.fmap ({text, ...}: text) x); 
        } 
      "readerWriter" = x: 
        { data = rwAlg (RW.fmap ({data, ...}: data) x); 
          text = initText; 
        };
    };
}
