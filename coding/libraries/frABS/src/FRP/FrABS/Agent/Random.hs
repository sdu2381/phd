{-# LANGUAGE Arrows #-}
module FRP.FrABS.Agent.Random 
  (
    {-
    agentRandom
  , agentRandomM

  , agentRandomRange
  , agentRandomRangeM
  , agentRandomRanges
  , agentRandomBoolProb
  , agentRandomBoolProbM
  , agentRandomSplit
  , agentRandomPick
  , agentRandomPickM
  , agentRandomPicks
  , agentRandomPicksM
  , agentRandomShuffle
  , agentRandomShuffleM
  -}

  randomBool
  , randomExp
  , randomShuffle

  , randomBoolM
  , randomExpM
  , avoidM

  , randomSF
  , randomBoolSF
  , drawRandomElemSF
  ) where

import Control.Monad.Random
-- import Control.Monad.Trans.State

import FRP.Yampa

-- import FRP.FrABS.Agent.Agent
import FRP.FrABS.Utils

{-
-------------------------------------------------------------------------------
-- RUNNING AGENT RANDOM-FUNCTION
-------------------------------------------------------------------------------
-- NOTE: beware of a = AgentOut (randomly manipulating AgentOut) because one will end up with 2 versions of AgentOut which need to be merged
agentRandom :: Rand StdGen a -> AgentOut s m e -> (a, AgentOut s m e)
agentRandom f ao = (ret, ao')
  where
    g = aoRng ao
    (ret, g') = runRand f g
    ao' = ao { aoRng = g' }

agentRandomM :: Rand StdGen a -> State (AgentOut s m e) a
agentRandomM f = state (runAgentRandomMAux f)
  where
    runAgentRandomMAux :: Rand StdGen a -> AgentOut s m e -> (a, AgentOut s m e)
    runAgentRandomMAux f ao = agentRandom f ao
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- AGENT RANDOM-FUNCTIONS
-------------------------------------------------------------------------------
agentRandomRange :: (Random a) => (a, a) -> AgentOut s m e -> (a, AgentOut s m e)
agentRandomRange r a = agentRandom (getRandomR r) a 

agentRandomRangeM :: (Random a) => (a, a) -> State (AgentOut s m e) a
agentRandomRangeM r = state (\ao -> agentRandomRange r ao)

agentRandomRanges :: (Random a) => (a, a) -> Int -> AgentOut s m e -> ([a], AgentOut s m e)
agentRandomRanges r n ao = agentRandom agentRandomRangesAux ao 
  where
    agentRandomRangesAux = getRandomRs r >>= (\infRand -> return $ take n infRand)

agentRandomBoolProb :: Double -> AgentOut s m e -> (Bool, AgentOut s m e)
agentRandomBoolProb p ao = agentRandom (randomBoolM p) ao

agentRandomBoolProbM :: Double -> State (AgentOut s m e) Bool
agentRandomBoolProbM p = state agentRandomBoolProbMAux 
  where
    agentRandomBoolProbMAux :: (AgentOut s m e) -> (Bool, AgentOut s m e)
    agentRandomBoolProbMAux ao = agentRandomBoolProb p ao

agentRandomSplit :: AgentOut s m e -> (StdGen, AgentOut s m e)
agentRandomSplit ao = agentRandom getSplit ao 

agentRandomPick :: [a] -> AgentOut s m e -> (a, AgentOut s m e)
agentRandomPick xs ao 
    | null xs = error "cannot draw single random element from empty list"
    | otherwise = (randElem, ao')
  where
    cellCount = length xs
    (randIdx, ao') = agentRandomRange (0, cellCount - 1) ao 
    randElem = xs !! randIdx

agentRandomPickM :: [a] -> State (AgentOut s m e) a
agentRandomPickM xs = state (\ao -> agentRandomPick xs ao)

agentRandomPicks :: [a] -> Int -> AgentOut s m e -> ([a], AgentOut s m e)
agentRandomPicks xs n ao 
    | null xs = error "cannot draw multiple random elements from empty list"
    | otherwise = (randElems, ao')
  where
    cellCount = length xs
    (randIndices, ao') = agentRandomRanges (0, cellCount - 1) n ao 
    randElems = foldr (\idx acc -> (xs !! idx) : acc) [] randIndices  

agentRandomPicksM :: [a] -> Int -> State (AgentOut s m e) [a]
agentRandomPicksM xs n = state (\ao -> agentRandomPicks xs n ao)

agentRandomShuffle :: [a] -> AgentOut s m e -> ([a], AgentOut s m e)
agentRandomShuffle xs ao = (xs', ao')
  where
    g = aoRng ao
    (xs', g') = randomShuffle g xs
    ao' = ao {aoRng = g'}

agentRandomShuffleM :: [a] -> State (AgentOut s m e) [a]
agentRandomShuffleM xs = state (\ao -> agentRandomShuffle xs ao)
-------------------------------------------------------------------------------
-}
-------------------------------------------------------------------------------
-- PURE RANDOM
-------------------------------------------------------------------------------
randomBool :: RandomGen g => g -> Double -> (Bool, g)
randomBool g p = runRand (randomBoolM p) g

randomExp :: RandomGen g => g -> Double -> (Double, g)
randomExp g lambda = runRand (randomExpM lambda) g

randomShuffle :: RandomGen g => g -> [a] -> ([a], g)
randomShuffle = fisherYatesShuffle

-------------------------------------------------------------------------------
-- MONADIC RANDOM
-------------------------------------------------------------------------------
randomBoolM :: RandomGen g => Double -> Rand g Bool
randomBoolM p = getRandomR (0.0, 1.0) >>= (\r -> return $ p >= r)

-- NOTE: THIS CODE INSPIRED BY Euterpea-1.0.0 (I didn't want to create dependencies and their implementation seems neat and tidy)
randomExpM :: RandomGen g => Double -> Rand g Double
randomExpM lambda = avoidM 0 >>= (\r -> return $ ((-log r) / lambda))
--randomExpM lambda = avoid 0 >>= (\r -> 1 - exp (-(dt/t_avg)))

-- NOTE: THIS CODE INSPIRED BY Euterpea-1.0.0 (I didn't want to create dependencies and their implementation seems neat and tidy)
avoidM :: (Random a, Eq a, RandomGen g) => a -> Rand g a
avoidM x = do
  r <- getRandom
  if (r == x) 
    then avoidM x
    else return r

-------------------------------------------------------------------------------
-- FRP RANDOM
-------------------------------------------------------------------------------
randomSF :: RandomGen g => g -> SF (Rand g a) a
randomSF initRng = proc f -> do
  rec
    g' <- iPre initRng -< g
    let (a, g) = runRand f g'

  returnA -< a

randomBoolSF :: (RandomGen g) => g -> Double -> SF () Bool
randomBoolSF g p = proc _ -> do
  r <- noiseR ((0, 1) :: (Double, Double)) g -< ()
  returnA -< (r <= p)

drawRandomElemSF :: (RandomGen g, Show a) => g -> SF [a] a
drawRandomElemSF g = proc as -> do
  r <- noiseR ((0, 1) :: (Double, Double)) g -< ()
  let len = length as
  let idx = (fromIntegral $ len) * r
  let a =  as !! (floor idx)
  returnA -< a