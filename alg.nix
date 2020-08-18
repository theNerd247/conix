# WriterF e a =
#  = Censor ([e] -> [e]) a
#  | Tell e a
# 
# datas :: WriterF e (Content a) -> Content a
#
# censor :: ([e] -> [e]) -> a -> WriterF e a
#
# onMerged :: (e -> e) -> a -> WriterF e a
# onMerged f = censor (pure . f . fold)
#
# labelData :: Path -> Content a -> Content a
# labelData path = datas . onMerged (nest path)
#
# ContentF a
#  = Drvs  (WriterF Drv a)
#  | Texts (WriterF Text a)
#  | Datas (WriterF AttrSet a)
#  | null
let
  W = import ./writerF.nix;
  M = import ./match.nix;
in
rec
{

  _drvs
    # WriterF Drv a -> ContentF a
    = next:
    { _type = "drvs";
      inherit next;
    };

  _texts
    # WriterF String a -> ContentF a
    = next:
    { _type = "texts";
      inherit next;
    };

  _datas
    # WriterF AttrSet a -> ContentF a
    = next:
    { _type = "datas";
      inherit next;
    };

  _end
    = { _type = "end"; };

  # TODO: verify this implementation does create infinite recursions.
  fmap = f: M.match 
  { end   = x: x;
    drvs  = M.modifyNext (W.fmap f);
    texts = M.modifyNext (W.fmap f);
    datas = M.modifyNext (W.fmap f);
  };

  evalWriterF = label: x:
    x.next.next // { ${label} = W.eval (W.fmap (r: r.${label}) x.next); };

  emptyResult = { drvs = []; texts = []; datas = []; };

  eval = M.match
    { end  = _: emptyResult; 
      drvs = evalWriterF "drvs";
      texts = evalWriterF "texts";
      datas = evalWriterF "datas";
    };
}
