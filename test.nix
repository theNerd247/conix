let
  pkgs = import <nixpkgs> {};

  lm = 
  { 
    mempty = [];
    mappend = a: b: a ++ b;
  };

  RW = import ./lib/rw.nix lm;

  test = e: c: 
  let
    expected = e 7;
    computed = c 7;
  in
  { 
    inherit expected computed;

    res = expected == computed;
  };

  f = x: x + 1;
  g = x: 2 * x;
  gf = d g f;
  h = xs: xs ++ [8];
  i = xs: [9] ++ xs;
  hi = d h i;
  d = s: t: x: s (t x);
in

with RW;
{
  functor = 
  {
    id = test (fmap (x: x) (pure 2)) (pure 2);
    comp = test (fmap (x: g (f x)) (pure 2)) (fmap g (fmap f (pure 2)));
  };

  applicative =
  {
    homo = test (ap (pure f) (pure 2)) (pure (f 2));
    comp = test 
      (ap (ap (ap (pure d) (pure f)) (pure g)) (pure 2))
      (ap (pure f) (ap (pure g) (pure 2)));
  };

  writer = 
  {
    emptyIdentity = test (rap (tell [1]) (pure null)) (rap (pure null) (tell [1]));
    tellTwice = test (rap (tell [1]) (tell [2])) (tell [1 2]);
    censorComp = test (censor h (censor i (tell [2]))) (censor hi (tell [2]));
  };

  reader = 
  {
    localComp = test (local f (local g get)) (local gf get);
  };

  fix = 
  {
    onlyTell = test (_: pkgs.lib.fix (tell [2])) (tell [2]);
  };
}
