module Renderer 
  (
    AgentObservable

  , renderSugarScapeFrame
  ) where

import           FRP.BearRiver
import qualified Graphics.Gloss as GLO

import           AgentMonad
import           Discrete
import           Model

type SugEnvironmentRenderer = EnvRendererDisc2d SugEnvCell
type SugarScapeAgentRenderer = AgentRendererDisc2d SugAgentObservable

renderSugarScapeFrame :: (Int, Int) 
                      -> Time 
                      -> SugEnvironment
                      -> [AgentObservable SugAgentObservable]
                      -> GLO.Picture
renderSugarScapeFrame wSize@(wx, wy) t e ss
    = GLO.Pictures (envPics ++ agentPics) -- ++ [timeStepTxt])
  where
    (dx, dy) = dimensionsDisc2d e
    cellWidth = fromIntegral wx / fromIntegral dx
    cellHeight = fromIntegral wy / fromIntegral dy

    cells = allCellsWithCoords e

    -- agentPics = map (defaultAgentRendererDisc2d agentColorDiseased sugAgCoord (cellWidth, cellHeight) wSize) ss
    agentPics = map (sugarscapeAgentRenderer (cellWidth, cellHeight) wSize t) ss
    envPics = map (renderEnvCell (cellWidth, cellHeight) wSize t) cells

    _timeStepTxt = GLO.color GLO.black $ GLO.translate (-halfWSizeX) (halfWSizeY - 20) $ GLO.scale 0.1 0.1 $ GLO.Text (show t)

    halfWSizeX = fromIntegral wx / 2.0 
    halfWSizeY = fromIntegral wy / 2.0 

renderEnvCell :: SugEnvironmentRenderer
renderEnvCell r@(rw, rh) w _t (coord, cell)
    | sugarRatio <= 0.01 = GLO.blank
    | otherwise          = sugarLevelCircle
  where
    sugarColor = GLO.makeColor 0.9 0.9 0.0 1.0
    
    (x, y) = transformToWindow r w coord

    sugarLevel = sugEnvSugarLevel cell
    sugarRatio = sugarLevel / snd sugarCapacityRange

    sugarRadius = rw * realToFrac sugarRatio
    sugarLevelCircle = GLO.color sugarColor $ GLO.translate x y $ GLO.ThickCircle 0 sugarRadius
   
sugarscapeAgentRenderer :: SugarScapeAgentRenderer
sugarscapeAgentRenderer r@(rw, rh) w _t (aid, s) 
    = GLO.Pictures [circle, txt]
  where
    coord = sugObsCoord s
    color = GLO.blue

    (x, y) = transformToWindow r w coord 

    circle = GLO.color color $ GLO.translate x y $ GLO.ThickCircle 0 rw
    txt    = GLO.color GLO.white $ GLO.translate (x - (rw * 0.4)) (y - (rh * 0.1)) $ GLO.scale 0.04 0.04 $ GLO.Text (show aid)

-------------------------------------------------------------------------------
type AgentObservable o   = (AgentId, o)
                            
type AgentRendererDisc2d s = (Float, Float) 
                           -> (Int, Int) 
                           -> Time
                           -> (AgentId, s)
                           -> GLO.Picture

type EnvRendererDisc2d c        = (Float, Float) 
                                -> (Int, Int)
                                -> Time 
                                -> (Discrete2dCoord, c) 
                                -> GLO.Picture

transformToWindow :: (Float, Float)
                      -> (Int, Int) 
                      -> Discrete2dCoord 
                      -> (Float, Float)
transformToWindow (rw, rh) (wx, wy) (x, y) = (x', y')
  where
    halfXSize = fromRational (toRational wx / 2.0)
    halfYSize = fromRational (toRational wy / 2.0)

    x' = fromRational (toRational (fromIntegral x * rw)) - halfXSize
    y' = fromRational (toRational (fromIntegral y * rh)) - halfYSize