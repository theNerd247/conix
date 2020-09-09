types:

rec
{ 
  # Note: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).

  docs.markup.text.type = "String -> MarkupF a";
  text = types.typed "text";

  docs.markup.text.fmap.type = "(a -> b) -> MarkupF a -> MarkupF b";
  fmap = f: types.match
    { "text"    = t: text t;
    };

  docs.markup.constructText.type = "MarkupF String -> String";
  constructText = types.match
    { "text" = t: t;
    };

  pure = _: text "";
}
