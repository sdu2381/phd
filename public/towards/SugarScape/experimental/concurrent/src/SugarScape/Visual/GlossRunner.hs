module SugarScape.Visual.GlossRunner
  ( runGloss
  ) where

import Data.IORef

import Control.Monad.Random
import qualified Graphics.Gloss as GLO
import Graphics.Gloss.Interface.IO.Animate
import Graphics.Gloss.Interface.IO.Simulate

import SugarScape.Core.Scenario
import SugarScape.Core.Simulation
import SugarScape.Visual.Renderer

runGloss :: SugarScapeScenario
         -> SimulationState StdGen
         -> SimTickOut
         -> Int
         -> AgentColoring
         -> SiteColoring
         -> IO ()
runGloss params initSimState initOut stepsPerSec av cv = do
  let winSize  = (800, 800)
      winTitle = "SugarScape " ++ sgScenarioName params
      
  -- intiialize IORef which holds last simulation state
  ssRef <- newIORef initSimState

  if stepsPerSec > 0
    then
      -- run stimulation, driven by Gloss
      simulateIO 
        (displayGlossWindow winTitle winSize) -- window title and size
        white                     -- background
        stepsPerSec               -- how many steps of the simulation to calculate per second (roughly, depends on rendering performance)
        initOut                   -- initial model = output of each simulation step to be rendered
        (modelToPicture winSize av cv)  -- model-to-picture function
        (renderStep ssRef)    -- 
    else
      animateIO
        (displayGlossWindow winTitle winSize)
        white
        (renderStepAnimate winSize ssRef av cv)
        (const $ return ())

displayGlossWindow :: String -> (Int, Int) -> GLO.Display
displayGlossWindow winTitle winSize = GLO.InWindow winTitle winSize (0, 0)

modelToPicture :: (Int, Int)
               -> AgentColoring
               -> SiteColoring
               -> SimTickOut
               -> IO GLO.Picture
modelToPicture winSize av cv (t, env, as) 
  = return $ renderSugarScapeFrame winSize t env as av cv

renderStep :: IORef (SimulationState StdGen)
           -> ViewPort
           -> Float
           -> SimTickOut
           -> IO SimTickOut
renderStep ssRef _ _ _ = do
  ss <- readIORef ssRef
  (ss', out) <- simulationTick ss
  writeIORef ssRef ss'
  
  return out

renderStepAnimate :: (Int, Int)
                  -> IORef (SimulationState StdGen)
                  -> AgentColoring
                  -> SiteColoring
                  -> Float
                  -> IO GLO.Picture
renderStepAnimate winSize ssRef av cv _ = do
  ss <- readIORef ssRef
  (ss', out) <- simulationTick ss
  writeIORef ssRef ss'

  modelToPicture winSize av cv out