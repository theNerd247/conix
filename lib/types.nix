rec 
{ 
  docs.typed.type = "String -> a -> { _type :: String, _val :: a }";
  typed = _type: _val: { inherit _type _val; };

  docs.match.type = "Map String (a -> b) -> { _type :: String, _val :: a} -> b";
  match = fs: x:
    let
      types = builtins.concatStringsSep ", " (builtins.attrNames fs);
      badType = throw "Invalid type in pattern match. Must be one of:\n Expected  ${types}\n Received ${x._type or "no _type"}";
      noType = throw "Value must have _type and _val attribute. _type can be one of these strings: \n  ${types}\n recieved: ${builtins.typeOf x}";

      k = x._type or noType;
      f = fs.${k} or badType;
      v = x._val or noType;
    in
      f v;

  docs.matchWith.type = "(a -> Map String (b -> c)) -> a -> { _type :: String _val :: b} -> c";
  matchWith = mkMatch: x: match (mkMatch x);

  docs.cata.type = "Functor f => ((a -> b) -> f a -> f b) -> (f a -> a) -> Fix f -> a";
  cata = fmap: alg: let c = x: alg (fmap c x); in c;

  isTyped = x: x ? _type;
}
