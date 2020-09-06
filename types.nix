pkgs: 

rec 
{ 
  # Monadic values are assumed to have a _type attribute.
  # Pure values will ommit this.
  #
  # Label is encoded as Nix Attribute Sets.
  # This lends towards an optimal user experience:
  #
  #   ''(label "a.b.c" x)'' was the old way which
  # required ''(set "a.b.c" x)'' if `x` was a monadic value.
  #
  # The new API will be: ''{ a.b.c = x }''
  #
  # 
  # label :: Path -> NixValue -> Labelled
  # get :: Path -> Labelled -> NixValue
  #
  # How do we match on Functors composed of labels if the labels
  # have no _type attribute?
  #
  # [x]: How do we distinguish between pure values that are attribute sets
  # and labelled values? Pure values will have _type = "pure" on them.
  #
  # use foldAttrsIxCond maybe?
  # 
  # How do we write this? That is collect all the labelled values from the 
  # AST and combine into a single labelled value. 
  #
  # LabelledASTF f = CoFreeF (Maybe Path) f ???? A labelled AST is one in which some nodes
  # have labels attached to them. 
  #
  # collectLabelledPiecesAlg :: (Foldable f, f a ~ NixValue) => LabelledASTF f Labelled -> Labelled
  # collectLabelledPiecesAlg CoFreef Nothing     labels  = fold (labels :: f Labels)
  # collectLabelledPiecesAlg CoFreeF (Just path) labels  = nest path (fold labels) 
  #
  # Next step:  translate ^ into Nix code where:
  # 
  # ```
  # CoFreeF Nothing     labels ~ { _type = ...; }
  # CoFreeF (Just path) labels ~ { ${path} = { _type = ...; }}
  # ```
  #
  # `foldWithLabells :: (f a -> a) -> LabelledASTF f (a, Labelled) -> (a, Labelled)`
  #
  # ^^^ This might be a histomorphism or a zygomorphism (maybe para?) ....

  typed = _type: x: x // { _type; };

  match = fs: x:
    let
      types = builtins.concatStringsSep ", " (builtins.attrNames fs);
      badType = throw "Invalid type in pattern match. Must be one of:\n  ${types}";
      noType = throw "Value must have _type and _valattribute. One of: \n  ${types}";
    in
}
