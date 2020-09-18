{mappend, mempty}:

{
  # (Monoid m) => (a -> m) -> [a] -> m
  foldMap = f: builtins.foldl' (m: x: mappend m (f x)) mempty;

  # (Monoid m) => [m] -> m
  mconcat = foldMap (x: x);
}
