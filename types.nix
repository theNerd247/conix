pkgs: 

rec 
{ 
  typed = _type: _val: { inherit _type _val; };

  docs.pure.type = "a -> Pure a";
  pure = typed "pure";

  docs.fmapFree.type = "((a -> b) -> f a -> f b) -> (a -> b) -> Either (Pure a) (f a) -> Either (Pure a) (f b)";
  fmapFree = fmap: f: x:
    if x ? _type && x._type == "pure" then x else fmap f x;

  docs.composeFmap.type = "((a -> b) -> g a -> g b) -> ((a -> b) -> f a -> f b) -> (a -> b) -> g (f a) -> g (f b)";
  composeFmap = fmapG: fmapF: f: fmapG (fmapF f);

  match = fs: x:
    let
      types = builtins.concatStringsSep ", " (builtins.attrNames fs);
      badType = throw "Invalid type in pattern match. Must be one of:\n Expected  ${types}\n Received ${x._type or "no _type"}";
      noType = throw "Value must have _type and _val attribute. One of: \n  ${types}";

      k = x._type or noType;
      f = fs.${k} or badType;
      v = x._val or noType;
    in
      f v;

  docs.cata.type = "((a -> b) -> f a -> f b) -> (f a -> a) -> Fix f -> a";
  cata = fmap: alg: let c = x: alg (fmap c x); in c;
}
