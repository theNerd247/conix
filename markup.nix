let
  T = import ./types.nix;
in

rec
{ 
  # MarkupF a
  # = Text String
  # | Doc [a]

  # NOTE: for now we'll use the final encoding of documents. However,
  # In the future it might be useful to use the inital encoding
  # (like a copy of the Pandoc AST).
  docs.markup.text.type = "String -> Markup";
  text = T.typed "text";
}
