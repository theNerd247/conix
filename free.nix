let
  T = import ./types.nix;
in

rec
{

  # NOTE: pure also is type Freer f a <==> b ~ Freer f a
  # because Nix is untyped we don't worry about writing type wrappers
  # like haskell's newtype
  docs.free.pure.type = "a -> FreerF f a b";
  pure = T.typed "pure";

  docs.free.free.type = "{ _fval :: f x, _next :: (x -> b) } -> FreerF f a b";
  free = T.typed "free";

  fmapMatch = f:
    { "pure" = x: x; 
      "free" = {_fval, _next}: free { inherit _fval; _next = x: f (_next (x)); };
    };

  docs.free.bindAlg.type = "(a -> Freer f b) -> FreerF f a (Freer f b) -> Freer f b";
  bindAlg = f: T.match
    { "pure" = x: f x;
      "free" = x: free x;
    };

  docs.free.fmapFreeF.type = "Functor f => (a -> b) -> FreerF f x a -> FreerF f x b";
  fmapFreeF = T.matchWith fmapMatch;

  # NOTE: Freer f a = Fix (FreerF f a) and thus
  # fmap, ap, and bind for Freer are all defined as a catamorphism over the
  # FreerF. This removes boiler plate code required to defined each instance
  # and enforces the Functor, Applicative, and Monad laws for free.
  docs.free.fmap.type = "(a -> b) -> Free f a -> Free f b";
  fmap = T.cata fmapFreeF (bindAlg (x: pure (f x));

  docs.free.ap.type = "Free f (a -> b) -> Free f a -> Free f b";
  ap = ff: x: T.cata fmapFreeF (bindAlg (f: fmap f x)) ff;

  docs.free.bind.type = "Free f a -> (a -> Free f b) -> Free f b";
  bind = x: f: T.cata fmapFreeF (bindAlg f) x;

  docs.free.traverse_.type = "(x -> Freer f a) -> [x] -> Freer f ()";
  traverse_ = f: 
    let 
      cons = x: xs: [x] ++ [xs];
    in
      builtins.foldl' (fnill: x: bind (f x) (_: fnill)) (pure null);

  docs.free.sequence_.type = "[Freer f a] -> Freer f [a]";
  sequence_ = traverse_ (x: x);
}
