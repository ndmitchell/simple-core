module Monad (
    MonadPlus(mzero, mplus),
    join, guard, when, unless, ap,
    msum,
    filterM, mapAndUnzipM, zipWithM, zipWithM_, foldM, 
    liftM, liftM2, liftM3, liftM4, liftM5,

    -- ...and what the Prelude exports
    Monad((>>=), (>>), return, fail),
    Functor(fmap),
    mapM, mapM_, sequence, sequence_, (=<<), 
    ) where


-- The MonadPlus class definition

class  (Monad m) => MonadPlus m  where
    mzero  :: m a
    mplus  :: m a -> m a -> m a


-- Instances of MonadPlus

instance  MonadPlus Maybe  where
    mzero                 = Nothing

    xs `mplus` ys = case xs of
        Nothing -> ys
        Just _ -> xs

instance  MonadPlus []  where
    mzero =  []
    mplus = (++)


-- Functions    


msum   :: MonadPlus m => [m a] -> m a
msum xs  =  foldr mplus mzero xs

join             :: (Monad m) => m (m a) -> m a
join x           =  x >>= id

when             :: (Monad m) => Bool -> m () -> m ()
when p s         =  if p then s else return ()

unless           :: (Monad m) => Bool -> m () -> m ()
unless p s       =  when (not p) s

ap               :: (Monad m) => m (a -> b) -> m a -> m b
ap               =  liftM2 ($)

guard            :: MonadPlus m => Bool -> m ()
guard p          =  if p then return () else mzero

mapAndUnzipM     :: (Monad m) => (a -> m (b,c)) -> [a] -> m ([b], [c])
mapAndUnzipM f xs = sequence (map f xs) >>= return . unzip

zipWithM         :: (Monad m) => (a -> b -> m c) -> [a] -> [b] -> m [c]
zipWithM f xs ys =  sequence (zipWith f xs ys)

zipWithM_         :: (Monad m) => (a -> b -> m c) -> [a] -> [b] -> m ()
zipWithM_ f xs ys =  sequence_ (zipWith f xs ys)

foldM            :: (Monad m) => (a -> b -> m a) -> a -> [b] -> m a
foldM f a xs = case xs of
  [] -> return a
  x:xs -> f a x >>= \ y -> foldM f y xs

filterM :: Monad m => (a -> m Bool) -> [a] -> m [a]
filterM p xs = case xs of
  [] -> return []
  x:xs ->
      p x >>= \b ->
      filterM p xs >>= \ys ->
      return (if b then (x:ys) else ys)

liftM            :: (Monad m) => (a -> b) -> (m a -> m b)
liftM f          =  \a -> a >>= \a' -> return (f a')

liftM2           :: (Monad m) => (a -> b -> c) -> (m a -> m b -> m c)
liftM2 f         =  \a b -> a >>= \a' -> b >>= \b' -> return (f a' b')

liftM3           :: (Monad m) => (a -> b -> c -> d) ->
                                 (m a -> m b -> m c -> m d)
liftM3 f         =  \a b c -> a >>= \a' -> b >>= \b' -> c >>= \c' -> return (f a' b' c')
