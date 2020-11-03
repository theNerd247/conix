# Given a monoid M create an API for the ReaderWriter Applicative stack 
# I'm forgoing monads for now to prevent infinite recursion issues.
M:

# type RW r w  a = r -> { val :: a, w :: w }
rec
{
  # a -> RW r w a
  pure = val: _: { inherit val; w = M.mempty; };

  # (a -> b) -> RW r w a -> RW r w b
  fmap = f: g: x: 
    let
      r = g x;
    in
      { val = f r.val; w = r.w; };

  # RW r w (a -> b) -> RW r w a -> RW r w b
  ap = ff: g: x: 
    let
      f = ff x;
      r = g x;
    in
      { val = f.val r.val; w = M.mappend f.w r.w; };

  # (a -> b -> c) -> RW r w a -> RW r w b -> RW r w c
  liftA2 = f: x: y: ap (fmap f x) y;

  # synonym of Haskell's (<*) operator
  # 
  # RW r w a -> RW r w b -> RW r w a
  lap = liftA2 (a: b: a);

  # synonym of Haskell's (*>) operator
  #
  # RW r w a -> RW r w b -> RW r w b
  rap = liftA2 (a: b: b);

  # Shorthand for a *> x <* b
  sap = a: x: b: rap a (lap x b);

  # (a -> RW r w b) -> [a] -> RW r w [b]
  traverse = f:
    builtins.foldl' (fbs: a: liftA2 (b: bs: [b] ++ [bs]) fbs (f a)) (pure []);

  # (a -> RW r w b) -> [a] -> RW r w ()
  traverse_ = f:
    builtins.foldl' (fb: a: rap fb (f a)) (pure null);

  # [RW r w a] -> RW r w [b]
  sequence = traverse (x: x); 

  # [RW r w a] -> RW r w ()
  sequence_ = traverse_ (x: x);

  # Only the Reader instance for join is provided
  # the for purpose of implementing `using`
  readerJoin = f: x: f x x;

  # W -> RW r w ()
  tell = w: _: { val = null; inherit w; };

  # RW r w r
  get = x: { val = x; w = M.mempty; };

  # (r' -> r) -> (r -> a) -> (r' -> a)
  # (r -> r) -> RW r w a -> RW r w a
  local = f: g: x: g (f x);

  # (r -> r) -> RW r w a -> RW r w a
  censor = f: g: x:
    let
      r = g x;
    in
      { inherit (r) val; w = f r.w; };

  # RW r w a -> r -> w
  exe = f: x: (f x).w;
}
