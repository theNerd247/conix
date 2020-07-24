self: super:

# HtmlPages -> Derivation
htmlPages:
  foldUntil (page: page ? content) (

    Path -> a -> Derivation-Content
    Path -> a -> link
