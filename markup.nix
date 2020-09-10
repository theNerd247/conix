types:

rec
{ 
  # NOTE: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).
  docs.markup.text.type = "String -> MarkupF a";
  text = types.typed "text";

  pure = _: text "";

  docs.markup.doc.type = "[a] -> MarkupF a";
  doc = types.typed "doc";

  fmapMatch = f: 
    { "text" = t: text t;
      "doc"  = ts: doc (builtins.map f ts);
    };
}
