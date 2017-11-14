module SocialForce.Model (
      SocialForceMsg (..)
    , SocialForceEnvironment (..)
    , SocialForceAgentState (..)

    , PersonColor

    , SocialForceAgentDef
    , SocialForceAgentBehaviour
    , SocialForceAgentIn
    , SocialForceAgentOut
    , SocialForceAgentObservable

    , SocialForceAgentMonadicBehaviour
    , SocialForceAgentMonadicBehaviourReadEnv
    , SocialForceAgentMonadicBehaviourNoEnv

    , unitTime
    
    , museumId
    , enterSpeed
    , groupSpawningProb
    , pre_ppl_psy 
    , pre_range
    , pre_angle
    , pre_wall_psy

    , whiteColor
    , randomColor
  ) where

import Control.Monad.Random

import FRP.FrABS

import SocialForce.Markup

data SocialForceMsg = SocialForceMsg

data SocialForceEnvironment = SocialForceEnvironment
  {
      sfEnvWalls :: [Wall]
  } deriving Show

type PersonColor = (Int, Int, Int)

data SocialForceAgentState = 
    Museum 
    {
        musStartPoint   :: Continuous2dCoord
      , musGroupPoint0  :: Continuous2dCoord
      , musGroupPoints  :: [Continuous2dCoord]
    }
  | Person
    {
        perPos          :: Continuous2dCoord
      , perArrivedDest  :: Bool
      , perHeading      :: Double
      , perVi0          :: Double
      , perAi           :: Double
      , perBi           :: Double
      , perK            :: Double
      , perk            :: Double
      , perRi           :: Double
      , perMi           :: Double
      , perDest         :: Continuous2dCoord
      , perConRange     :: Double
      , perAttRange     :: Double
      , perAiWall       :: Double
      , perAiGrp        :: Double
      , perColor        :: PersonColor
      , perBelGroup     :: Maybe AgentId
      , perDestScreen   :: AgentId
    } deriving Show

type SocialForceAgentDef = AgentDef SocialForceAgentState SocialForceMsg SocialForceEnvironment
type SocialForceAgentBehaviour = AgentBehaviour SocialForceAgentState SocialForceMsg SocialForceEnvironment
type SocialForceAgentIn = AgentIn SocialForceAgentState SocialForceMsg SocialForceEnvironment
type SocialForceAgentOut = AgentOut SocialForceAgentState SocialForceMsg SocialForceEnvironment
type SocialForceAgentObservable = AgentObservable SocialForceAgentState

type SocialForceAgentMonadicBehaviour = AgentMonadicBehaviour SocialForceAgentState SocialForceMsg SocialForceEnvironment
type SocialForceAgentMonadicBehaviourReadEnv = AgentMonadicBehaviourReadEnv SocialForceAgentState SocialForceMsg SocialForceEnvironment
type SocialForceAgentMonadicBehaviourNoEnv = AgentMonadicBehaviourNoEnv SocialForceAgentState SocialForceMsg SocialForceEnvironment

unitTime :: DTime
unitTime = 0.1

museumId :: AgentId
museumId = 0

enterSpeed :: Double
enterSpeed = 2 -- TODO: re-set to 7

groupSpawningProb :: Double
groupSpawningProb = 0.3

pre_ppl_psy :: Double 
pre_ppl_psy = 2

pre_range :: Double 
pre_range = 10

pre_angle :: Double 
pre_angle = 5 * pi / 6;

pre_wall_psy :: Double
pre_wall_psy = 2

whiteColor :: PersonColor
whiteColor = (255, 255, 255)

randomColor :: Rand StdGen PersonColor
randomColor = do
  r <- getRandomR (0, 255)
  g <- getRandomR (0, 255)
  b <- getRandomR (0, 255)
  return (r, g, b)