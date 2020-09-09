{typed, match}: rw:

rec
{ 
  # Note: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).

  docs.content.text.type = "Text -> ContentF a";
  text = typed "text";

  docs.text.fmap.type = "(a -> b) -> ContentF a -> ContentF b";
  fmap = f: match
    { "text"    = t: text t;
    };

  pure = _: text "";

  # Fix (G . F) ~ G (Fix (F . G))
  # 
  # => (G . F) ((G . F) (...))
  #
  # => G (F (G (F (...)))) 
  #
  # => G ((F . G) ((F . G) (...)))
  # 
  # => G (Fix (F . G))
  #
  # Therefor the outer functor determines the final evaluated value
  # of the fold.

  #TODO: write 
  # pure :: a -> StateF a
  # eval :: StateF (ContentF (AttrSet -> AttrSet) -> AttrSet -> AttrSet
  # sequence :: [m a] -> m a

}
