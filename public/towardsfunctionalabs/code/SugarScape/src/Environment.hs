module Environment 
  (
    cellUnoccupied
  , cellOccupied
  
  , regrowRates
  , regrow

  , diffusePolution

  -- , SugEnvironmentBehaviour
  ) where

import Control.Monad
import Control.Monad.Trans.State

import Data.Maybe

import Discrete
import Model
import Utils

------------------------------------------------------------------------------------------------------------------------
-- ENVIRONMENT-BEHAVIOUR
------------------------------------------------------------------------------------------------------------------------
cellOccupied :: SugEnvCell -> Bool
cellOccupied cell = isJust $ sugEnvOccupier cell

cellUnoccupied :: SugEnvCell -> Bool
cellUnoccupied = not . cellOccupied

diffusePolution :: Double -> State SugEnvironment ()
diffusePolution t 
    | timeReached && _enablePolution_ = updateCellsM (\c -> c { sugEnvPolutionLevel = 0.0 })
    | otherwise = return ()
  where
    timeReached = mod (floor t) diffusePolutionTime == 0

regrowSugar :: Double -> State SugEnvironment ()
regrowSugar rate
    | rate < 0 = regrowSugarToMax
    | otherwise = regrowSugarByRate
  where
    regrowSugarByRate :: State SugEnvironment ()
    regrowSugarByRate  
      = updateCellsM (\c -> 
        c { sugEnvSugarLevel = 
              min
                  (sugEnvSugarCapacity c)
                  (sugEnvSugarLevel c) + rate})

    regrowSugarToMax :: State SugEnvironment ()
    regrowSugarToMax = updateCellsM (\c -> c { sugEnvSugarLevel = sugEnvSugarCapacity c})

regrowSpice :: Double -> State SugEnvironment ()
regrowSpice rate
    | rate < 0 = regrowSpiceToMax
    | otherwise = regrowSpiceByRate
  where
    regrowSpiceByRate :: State SugEnvironment ()
    regrowSpiceByRate 
      = updateCellsM (\c -> 
        c { sugEnvSpiceLevel = 
              min
                  (sugEnvSpiceCapacity c)
                  (sugEnvSpiceLevel c) + rate})

    regrowSpiceToMax ::  State SugEnvironment ()
    regrowSpiceToMax = updateCellsM (\c -> c { sugEnvSpiceLevel = sugEnvSpiceCapacity c })

regrowSugarByRateAndRegion :: Discrete2dDimension -> Double -> State SugEnvironment ()
regrowSugarByRateAndRegion range rate = updateCellsWithCoordsM (regrowCell range)                        
  where
    regrowCell :: Discrete2dDimension -> (Discrete2dCoord, SugEnvCell) -> SugEnvCell
    regrowCell (fromY, toY) ((_, y), c)
      | y >= fromY && y <= toY = c {
                                      sugEnvSugarLevel = 
                                          min
                                              (sugEnvSugarCapacity c)
                                              (sugEnvSugarLevel c) + rate}
      | otherwise = c

regrowSpiceByRateAndRegion :: Discrete2dDimension -> Double -> State SugEnvironment ()
regrowSpiceByRateAndRegion range rate = updateCellsWithCoordsM (regrowCell range)
  where
    regrowCell :: Discrete2dDimension -> (Discrete2dCoord, SugEnvCell) -> SugEnvCell
    regrowCell (fromY, toY) ((_, y), c)
      | y >= fromY && y <= toY = c {
                                      sugEnvSpiceLevel = 
                                          min
                                              (sugEnvSpiceCapacity c)
                                              (sugEnvSpiceLevel c) + rate}
      | otherwise = c

regrowSeasons :: Double -> State SugEnvironment ()
regrowSeasons t = do
    (_, maxY) <- dimensionsDisc2dM
    
    let halfY = floor (toRational (fromIntegral maxY :: Int) / 2.0 )
    let summerRange = if summerOnTop then (1, halfY) else (halfY + 1, maxY)
    let winterRange = if winterOnTop then (1, halfY) else (halfY + 1, maxY)

    regrowSugarByRateAndRegion summerRange sugarSummerRate
    regrowSugarByRateAndRegion winterRange sugarWinterRate

    when _enableSpice_ (regrowSpiceByRateAndRegion summerRange spiceSummerRate)
    when _enableSpice_ (regrowSpiceByRateAndRegion winterRange spiceWinterRate)
  where
    r = floor (t / seasonDuration) :: Int
    summerOnTop = even r
    winterOnTop = not summerOnTop

    sugarSummerRate = sugarGrowbackUnits / summerSeasonSugarGrowbackRatio
    sugarWinterRate = sugarGrowbackUnits / winterSeasonSugarGrowbackRatio

    spiceSummerRate = spiceGrowbackUnits / summerSeasonSpiceGrowbackRatio
    spiceWinterRate = spiceGrowbackUnits / winterSeasonSpiceGrowbackRatio 

regrowRates :: State SugEnvironment ()
regrowRates = regrowSugar sugarGrowbackUnits >> when _enableSpice_ (regrowSpice spiceGrowbackUnits)

regrow :: Double -> State SugEnvironment ()
regrow t = ifThenElse _enableSeasons_ (regrowSeasons t) regrowRates

{-
behaviourM :: SugEnvironmentMonadicBehaviour
behaviourM time = 
    do
        diffusePolution time
        regrow time
        return $ trace ("Time = " ++ show time) ()

SugEnvironmentBehaviour :: SugEnvironmentBehaviour
SugEnvironmentBehaviour = environmentMonadic behaviourM
-}