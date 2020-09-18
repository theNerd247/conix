{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}

module Main where

import Prelude hiding (text)
import Control.Monad.Fix (mfix)
import Control.Monad (join)
import Data.Monoid (Sum(..))
import Data.String (IsString(..))
import Data.List (intersperse)

main :: IO ()
main = pure (runRW $ test) >>= putStrLn . show

test :: (r ~ [(String, Int)]) => r -> FSM r ()
test = \x -> dir "x" 
  [ dir "da" 
    [ file "md" "dafa" 
      [ tell [("foo", 3)] "bob"
      , tell [("bar", f x)] "\njoe"
      , text $ "\nblack - " <> (show . snd . (!! 0) $ x)
      , g x
      ]
    , file "md" "dafb" ["joey"]
    , dir "dada" $ [file "md" "jazz" []]
    ]
  , dir "db" [file "md" "dbfa" ["of all trades"]]
  ]
  where
    p x = fst (x !! 0)
    f x = case p x of
      "foo" -> 7
      _     -> 8

    g !x = case x of
      (_:(_, x):xs) -> tell [("glob", x)] $ pure ()
      (x:xs)   -> "\nIt's foo"
      _        -> ""

data FreeF f a b
  = PureF a
  | FreeF (f b)
  deriving Functor

newtype Free f a = Free { unFree :: Fix (FreeF f a) }

instance (Functor f) => Functor (Free f) where
  fmap f = freeCata $ freeAlg (pure . f)

instance (Functor f) => Applicative (Free f) where
  pure = Free . Fix . PureF
  ff <*> fx = freeCata (freeAlg (<$>fx)) ff

instance (Functor f) => Monad (Free f) where
  return = pure
  x >>= f = freeCata (freeAlg f) x

liftFree :: (Functor f) => f a -> Free f a
liftFree = Free . Fix . FreeF . fmap (unFree . pure)

wrapFree :: (Functor f) => f (Free f a) -> Free f a
wrapFree = Free . Fix . FreeF . fmap unFree

freeCata x = cata x . unFree

newtype Fix f = Fix { unFix :: f (Fix f) }

data FreerF f a b
  = PurerF a
  | forall x. FreerF (f x) (x -> b)

instance Functor (FreerF f a) where
  fmap _ (PurerF a)     = PurerF a
  fmap f (FreerF fx g) = FreerF fx (f . g)

newtype Freer f a = Freer { unFreer :: Fix (FreerF f a) }

liftFreer :: f a -> Freer f a
liftFreer x = Freer $ Fix $ FreerF x (unFreer . pure)

wrapFreer :: f (Freer f a) -> Freer f a
wrapFreer x = Freer . Fix $ FreerF x unFreer

cata :: (Functor f) => (f a -> a) -> Fix f -> a
cata alg = c where c = alg . fmap c . unFix

freerCata :: (FreerF f a b -> b) -> Freer f a -> b
freerCata f = cata f . unFreer

instance Functor (Freer f) where
  fmap f = freerCata (bindAlg $ pure . f)

instance Applicative (Freer f) where
  pure = Freer . Fix . PurerF
  f <*> x = freerCata (bindAlg (<$>x)) f

instance Monad (Freer f) where
  return = pure
  x >>= f = freerCata (bindAlg f) x

data Res r = Res
  { _text  :: String
  , _data  :: r
  , _files :: [String]
  } deriving (Show)

instance (Semigroup r) => Semigroup (Res r) where
  a <> b = Res
    { _text = (_text a) <> (_text b)
    , _data = (_data a) <> (_data b) 
    , _files = (_files a) <> (_files b)
    }

instance (Monoid r) => Monoid (Res r) where
  mempty = Res
    { _text = mempty
    , _data = mempty
    , _files = mempty
    }

newtype RenderType = RenderType { unRenderType :: String }
  deriving (Show, IsString)

newtype FileName = FileName { unFileName :: String }
  deriving (Show, IsString)

onlyText :: (Monoid r) => String -> Res r
onlyText t = Res { _text = t, _data = mempty, _files = mempty}

onlyData :: r -> Res r
onlyData d = Res { _text = mempty, _data = d, _files = mempty}

addFile :: RenderType -> FileName -> Res r -> Res r
addFile (RenderType "dir") n = _files >>= setFiles . (:[]) . mkDir n
addFile (RenderType typ) (FileName name) = do
  txt <- _text
  addLocal $ FileName $ "[" <> name <> "." <> typ <> ": " <> txt <> "]"

mkDir :: FileName -> [String] -> String
mkDir (FileName n) fs = "<" <> n <> ": " <> (mconcat $ intersperse "," fs) <> ">"

addLocal :: FileName -> Res r -> Res r
addLocal (FileName f) = _files >>= setFiles . (<> [f])

setFiles :: [String] -> Res r -> Res r
setFiles fs c = c { _files = fs }

data FSMF r a where
  File  :: RenderType -> FileName -> a -> FSMF r a
  Text  :: String -> FSMF r a
  Tell  :: r -> a -> FSMF r a
  Merge :: [a] -> FSMF r a
  deriving Functor

type FSM r = Free (FSMF r)

instance IsString (FSM r a) where
  fromString = text

instance Semigroup (FSM r a) where
  a <> b = wrapFree $ Merge [a, b]

instance Monoid (FSM r a) where
  mempty = liftFree $ Merge []

data RW r a where
  Ask :: RW r r

type Reader r = Freer (RW r)

ask :: Reader r r
ask = liftFreer Ask

tell :: r -> FSM r a -> FSM r a
tell r = wrapFree . Tell r

text :: String -> FSM r a
text = liftFree . Text

file :: RenderType -> FileName -> [FSM r a] -> FSM r a
file r n = wrapFree . File r n . mconcat

dir :: FileName -> [FSM r a] -> FSM r a
dir = file "dir"

bindAlg :: (a -> Freer f b) -> FreerF f a (Freer f b) -> Freer f b
bindAlg f (PurerF a)     = f a
bindAlg _ (FreerF fx g) = Freer $ Fix $ FreerF fx (unFreer . g)

freeAlg :: (Functor f) => (a -> Free f b) -> FreeF f a (Free f b) -> Free f b
freeAlg f (PureF a)  = f a
freeAlg _ (FreeF fx) = wrapFree fx

fsmAlg :: (Monoid r) => FreeF (FSMF r) a (Res r) -> Res r
fsmAlg (PureF _)              = mempty
fsmAlg (FreeF (Text s)      ) = onlyText s
fsmAlg (FreeF (File r n x)  ) = addFile r n x
fsmAlg (FreeF (Tell r x)    ) = onlyData r <> x
fsmAlg (FreeF (Merge xs)    ) = mconcat xs

-- printFSM :: (Show r, Show a) => FreeF (FSMF r) a String -> String
-- printFSM (PureF x)              = "PureF " <> (show x)
-- printFSM (FreeF (Text s)     g) = "FreeF (Text " <> s <> ")\n(" <> g () <> ")"
-- printFSM (FreeF (File r n x) g) = "FreeF (File " <> show r <> " " <> show n <> ")\n(" <> g x <> ")"
-- printFSM (FreeF (Tell r x)   g) = "FreeF (Tell " <> show r <> "\n(" <> g x <> ")"

evalFSM :: (Monoid r) => FSM r a -> Res r
evalFSM = freeCata fsmAlg

runRW :: (Monoid r) => (r -> FSM r a) -> Res r
runRW f = fix $ evalFSM . f . _data

fix :: (a -> a) -> a
fix f = f (fix f)
