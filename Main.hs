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

main :: IO ()
main = pure (runRW test) >>= putStrLn . show

test :: Reader [(String, Int)] ()
test = do 
  x <- ask
  tell [("foo", 3)]
  tell [("bar", f x)]
  ask >>= text . show . length
  tell [("baz", 6)]
  g x
  testFile
  where
    p x = fst (x !! 0)
    f x = case p x of
      "foo" -> 7
      _     -> 8

    g !x = case x of
      []     -> text "It's foo"
      (x:xs) -> tell [("glob", snd x)]

    testFile = do
      x <- ask
      file "md" "txt"
      text "bob"
      text $ "marley: " <> (show $ length x)

data FreerF f a b
  = PureF a
  | forall x. FreerF (f x) (x -> b)

instance Functor (FreerF f a) where
  fmap _ (PureF a)     = PureF a
  fmap f (FreerF fx g) = FreerF fx (f . g)

newtype Fix f = Fix { unFix :: f (Fix f) }

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
  pure = Freer . Fix . PureF
  f <*> x = freerCata (bindAlg (<$>x)) f

instance Monad (Freer f) where
  return = pure
  x >>= f = freerCata (bindAlg f) x

data ConixM r = ConixM
  { _text  :: String
  , _data  :: r
  , _files :: [String]
  } deriving (Show)

instance (Semigroup r) => Semigroup (ConixM r) where
  a <> b = ConixM
    { _text = (_text a) <> (_text b)
    , _data = (_data a) <> (_data b) 
    , _files = (_files a) <> (_files b)
    }

instance (Monoid r) => Monoid (ConixM r) where
  mempty = ConixM
    { _text = mempty
    , _data = mempty
    , _files = mempty
    }

newtype RenderType = RenderType { unRenderType :: String }
  deriving (Show, IsString)

newtype FileName = FileName { unFileName :: String }
  deriving (Show, IsString)

onlyText :: (Monoid r) => String -> ConixM r
onlyText t = ConixM { _text = t, _data = mempty, _files = mempty}

onlyData :: r -> ConixM r
onlyData d = ConixM { _text = mempty, _data = d, _files = mempty}

addFile :: RenderType -> FileName -> ConixM r -> ConixM r
addFile (RenderType t) (FileName n) c = 
  c { _files = (_files c) <> [newFile t n (_text c)] }
  where
    newFile typ name txt = name <> "." <> typ <> ": " <> txt 

data RW r a where
  Tell  :: r -> RW r ()
  Ask   :: RW r r
  Text  :: String -> RW r ()
  File  :: RenderType -> FileName -> RW r ()

type Reader r = Freer (RW r) 

tell :: r -> Reader r ()
tell = lift . Tell

ask :: Reader r r
ask = lift Ask

text :: String -> Reader r ()
text = lift . Text

file :: RenderType -> FileName -> Reader r ()
file r = lift . File r

bindAlg :: (a -> Freer f b) -> FreerF f a (Freer f b) -> Freer f b
bindAlg f (PureF a)     = f a
bindAlg _ (FreerF fx g) = Freer $ Fix $ FreerF fx (unFreer . g)

-- (Pure a) >>= f    = f a
-- (Freer x g) >>= f = Freer x ((>>=f) . g)

-- ask >>= (tell . f)
-- Freer Ask (\r -> Freer (Tell $ f r) pure)
-- fix $ \x -> (alg . fmap c . (\r -> Freer (Tell $ f r) pure)) x x
-- fix $ \x -> (alg . fmap c $ Freer (Tell $ f x) pure) x
-- fix $ \x -> (alg $ Freer (Tell $ f x) (alg . fmap c . pure)) x
-- fix $ \x -> (\x' -> (<>f x) <$> (alg . fmap c . pure) () x') x
-- fix $ \x -> (\x' -> (<>f x) <$> (\_ -> pure mempty) x') x
-- fix $ \x -> (\x' -> (<>f x) <$> (pure mempty)) x
-- fix $ \x -> (<>f x) <$> (pure mempty)
--
-- runRW $ ask >>= f
-- runRW $ Freer Ask f 
-- fix $ \x -> (alg . fmap c $ f x) x
--
-- x -> m
--
--
-- Freer (Place x) f
--
-- \x -> (f x) <$> (alg . fmap c . f) x

evalRWAlg :: (Monoid r) => FreerF (RW r) a (r -> ConixM r) -> r -> ConixM r
evalRWAlg (PureF _)             = \_ -> mempty
evalRWAlg (FreerF Ask g)        = \x -> g x x
evalRWAlg (FreerF (Tell r) g)   = \x -> onlyData r <> g () x
evalRWAlg (FreerF (Text s) g)   = \x -> onlyText s <>  g () x
evalRWAlg (FreerF (File t n) g) = \x -> addFile t n $ g () x

evalRW :: (Monoid r) => Reader r a -> r -> ConixM r
evalRW = freerCata evalRWAlg

runRW :: (Monoid r) => Reader r a -> ConixM r
runRW r = let f = evalRW r in fix $ f . _data

fix :: (a -> a) -> a
fix f = f (fix f)
