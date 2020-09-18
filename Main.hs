{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Main where

import Prelude hiding (text)
import Control.Monad.Fix (mfix)
import Control.Monad (join)
import Data.Monoid (Sum(..))
import Data.String (IsString(..))
import Data.List (intersperse)

main :: IO ()
main = pure (runRW test) >>= putStrLn . show

test :: (r ~ [(String, Int)]) => Reader r (FSM r a)
test = do 
  x <- ask
  let 
    testdir = file "dir" "foo" $
      [ file "md" "bob" $ 
          [ tell [("foo", 3)] >> text "bob"
          , tell [("bar", f x)] >> text "\njoe"
          , text $ "\nblack - " <> (show . snd . (!! 0) $ x)
          , g x
          ]
      , file "md" "joe" $ 
          [ text "joey"
          ]
      ]
  pure $ testdir
  where
    p x = fst (x !! 0)
    f x = case p x of
      "foo" -> 7
      _     -> 8

    g !x = case x of
      (_:x:xs) -> text "\nIt's foo"
      (x:xs)   -> tell [("glob", snd x)] >> text ""
      _        -> text ""

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

freeCata x = cata x . unFree

newtype Fix f = Fix { unFix :: f (Fix f) }

data FreerF f a b
  = PurerF a
  | forall x. FreerF (f x) (x -> b)

instance Functor (FreerF f a) where
  fmap _ (PurerF a)     = PurerF a
  fmap f (FreerF fx g) = FreerF fx (f . g)

newtype Freer f a = Freer { unFreer :: Fix (FreerF f a) }

lift :: f a -> Freer f a
lift x = Freer $ Fix $ FreerF x (unFreer . pure)

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

data FSMF r a
  = File RenderType FileName [a]
  | Text String
  | Tell r
  deriving Functor

type FSM r = Free (FSMF r)

data RW r a where
  Ask :: RW r r

type Reader r = Freer (RW r)

ask :: Reader r r
ask = lift Ask

tell :: r -> FSM r a 
tell = liftFree . Tell

text :: String -> FSM r a
text = liftFree . Text

file :: RenderType -> FileName -> [FSM r a] -> FSM r a
file r n = Free . Fix . FreeF . File r n . fmap unFree

-- dir :: FileName -> Reader r ()
-- dir = file "dir"
-- 
-- local :: FileName -> Reader r ()
-- local = lift . Local

bindAlg :: (a -> Freer f b) -> FreerF f a (Freer f b) -> Freer f b
bindAlg f (PurerF a)     = f a
bindAlg _ (FreerF fx g) = Freer $ Fix $ FreerF fx (unFreer . g)

freeAlg :: (Functor f) => (a -> Free f b) -> FreeF f a (Free f b) -> Free f b
freeAlg f (PureF a)  = f a
freeAlg _ (FreeF fx) = Free . Fix . FreeF $ fmap unFree $ fx

fsmAlg :: (Monoid r) => FreeF (FSMF r) a (Res r) -> Res r
fsmAlg (PureF _)             = mempty
fsmAlg (FreeF (Text s)     ) = onlyText s
fsmAlg (FreeF (File r n xs)) = addFile r n $ mconcat xs 
fsmAlg (FreeF (Tell r)   )   = onlyData r

evalRWAlg :: (Monoid r) => FreerF (RW r) (FSM r a) (r -> Res r) -> r -> Res r
evalRWAlg (PurerF x)             = pure $ cata fsmAlg $ unFree x
evalRWAlg (FreerF Ask g)        = join g
-- evalRWAlg (FreerF (Text s) g)   = (pure $ onlyText s) <> g ()
-- evalRWAlg (FreerF (File t n) g) = addFile t n <$> g ()
-- evalRWAlg (FreerF (Local f) g)  = addLocal f <$> g ()

evalRW :: (Monoid r) => Reader r (FSM r a) -> r -> Res r
evalRW = freerCata evalRWAlg

runRW :: (Monoid r) => Reader r (FSM r a) -> Res r
runRW r = let f = evalRW r in fix $ f . _data

fix :: (a -> a) -> a
fix f = f (fix f)
