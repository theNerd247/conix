rec
{
  # RF r a = r -> a

  # Monoid m => instance Monoid (RF r m)
  monoid = {mempty, mappend}:
    {
      mempty = _: mempty;
      mappend = f: g: x: mappend (f x) (g x);
    };

  # r -> RF r a -> RF r a
  join = f: x: f x x;

  # a -> RF r a
  pure = x: _: x;

  # (a -> b) -> RF a -> RF b
  fmap = f: g: x: f (g x);

  # ap
}
