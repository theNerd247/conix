types:

rec
{ 
  # Note: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).

  docs.content.text.type = "Text -> ContentF a";
  text = types.typed "text";

  docs.text.fmap.type = "(a -> b) -> ContentF a -> ContentF b";
  fmap = f: types.match
    { "text"    = t: text t;
    };

  pure = _: text "";

  #TODO: write 
  # pure :: a -> StateF a
  # eval :: StateF (ContentF (AttrSet -> AttrSet) -> AttrSet -> AttrSet
  # sequence :: [m a] -> m a

}
