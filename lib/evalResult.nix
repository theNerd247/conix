# NOTE:
# 
#  DO THIS:
# 
#  let 
#    r = f x;
#  in
#    g (x // { a = r.a; });
#
#  NOT THIS:
# 
#   g (x // (f x));
#
# The prior form prevents accidental evaluation of values that could bottom out
# and cause the program to error due to infinite recursion. While sematically
# the same, operationally { a = r.a } creates nested thunks that prevents 
# the (possibly) strict result of `f x` from evaluating.
pkgs:

let
  CJ = import ./copyJoin.nix pkgs;
in

# let
#  S = { data :: AttrSet, refs :: AttrSet }
#  R = { parentPath :: FilePathString }
#  W = { drv :: Derivation, text :: String, targetName :: First String }
#  X a = S * W * { val :: a }
#
# ResM a 
#  (logically)
#  = ReaderT R (StateT S (Writer W)) a
#  (what's implemented)
#  = ConixLib * { pkgs :: <nixpkgs> } * R * S -> X a
rec
{
  # a -> X a
  xPure = val:
    { 
      data = {}; 
      refs = {};
      drv = {};
      targetName = "";
      text = ""; 
      inherit val;
    };

  # (a -> b) -> X a -> X b
  xFmap = f: x:
    { 
      data = x.data;
      refs = x.refs;
      drv = x.drv;
      targetName = x.targetName;
      text = x.text;
      val = f x.val;
    };

  # X (a -> b) -> X a -> X b
  xAp = f: r:
    { 
      data = r.data;
      refs = r.refs;
      drv = mergeDrv f.targetName f.drv r.drv;
      targetName = f.targetName;
      text = f.text + r.text;
      val = f.val r.val;
    };

  # a -> ResF a
  pure = val: _: xPure val;

  # (a -> b) -> ResM a -> ResM b
  fmap = f: g: x:
    xFmap f (g x);

  # ResM (a -> b) -> ResM a -> ResM b
  ap = ff: g: x:
    let
      f = ff x;
      r = g (x // { data = f.data; refs = f.refs; });
    in
      xAp f r;

  # synonym of Haskell's (<*) operator
  # 
  # ResM a -> ResM b -> ResM a
  lap = liftA2 (a: b: a);

  # synonym of Haskell's (*>) operator
  #
  # ResM a -> ResM b -> ResM b
  rap = liftA2 (a: b: b);

  # Shorthand for a *> x <* b
  sap = a: x: b: rap a (lap x b);

  # (a -> b -> c) -> ResM a -> ResM b -> ResM c
  liftA2 = f: x: y: ap (fmap f x) y;

  # (a -> ResM b) -> [a] -> ResM [b]
  traverse = f:
    builtins.foldl' (fbs: a: liftA2 (b: bs: [b] ++ [bs]) (f a) fbs) (pure []);

  # (a -> ResM b) -> [a] -> ResM ()
  traverse_ = f:
    builtins.foldl' (fb: a: rap (f a) fb) (pure null);

  # [ResM a] -> ResM [b]
  sequence = traverse (x: x); 

  sequence_ = traverse_ (x: x);

  # (R * S -> ResM a) -> ResM a
  readerJoin = r: x: r x x;

  # String -> ResM ()
  tellText = text: (pure null) // { inherit text; };

  # (S -> S) -> ResM ()
  modify = f: {data, refs, ...}: 
    let
      r = f {data, refs};
    in
      (xPure null) // { data = r.data; refs = r.refs; };

  # S -> ResF ()
  set = x: modify (_: x);

  # ResF (S * R)
  get = {data, refs, parentPath, ...}: 
    xPure { inherit data refs parentPath; };

  # (S * R -> S * R) -> ResF a -> ResF a
  local = f: g: x@{data, refs, parentPath, ...}:
    let
      r = f { inherit data, refs, parentPath; };
    in
      g (x // { data = r.data; refs = r.refs; parentPath = r.parentPath; });

  # AttrSet -> AttrSet -> AttrSet
  mergeData = pkgs.lib.attrsets.recursiveUpdate; 

  # Derivation -> Derivation -> Derivation
  mergeDrv = targetName: a: b:
    let
      name = 
        if targetName != "" then targetName 
        else a.name or b.name or (builtins.baseNameOf a);
    in
         if a == {} && b == {} then {}
    else if a == {}            then b 
    else if b == {}            then a 
    else CJ.collect name [a b];

# { x = html "foo" [ ... ]; }
# 
# { x = R[ ... ]; } --> _anchor "x" [...] }

# 
# anchor "x" x --> x <* saveCurrentPathReference "x"
# file "foo" x --> appendPath "foo.html" *> x <* writeHtmlFile "foo"
# dir "foo"  x --> appendPath "/foo" *> x <* createDir "foo"
# 
#
#  (\"x" _next -> \path -> set "data.refs.${x}" (_next path).path)  }
#
# RefName -> m a -> m a
# \x _next -> m a <* modify (\s -> s // { data = s.data <> { data.refs.x = s.path; }; })
#
# where
#  modify :: (s -> s) -> m ()
#
# data.refs.x = "./foo.md"
#
# b -> (s -> (s, a)) -> (s -> (s, a))
}
