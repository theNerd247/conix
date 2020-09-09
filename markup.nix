types:

rec
{ 
  # Note: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).

  docs.markup.text.type = "String -> MarkupF a";
  text = types.typed "text";

  pure = _: text "";

  fmapMatch = f: 
    { "text" = t: text t;
    };
}
