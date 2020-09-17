let
  T = import ./types.nix;
in

rec
{

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
}
