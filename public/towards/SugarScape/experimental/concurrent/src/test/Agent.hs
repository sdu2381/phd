module Agent
  ( agentTests
  ) where

import Control.Monad.Random
import Data.Maybe

import Test.Tasty
import Test.Tasty.QuickCheck as QC

import SugarScape.Agent.Ageing
import SugarScape.Agent.Common
import SugarScape.Agent.Metabolism 
import SugarScape.Core.Common
import SugarScape.Core.Discrete
import SugarScape.Core.Model
import SugarScape.Core.Scenario

import Runner

instance Arbitrary SugAgentState where
  -- arbitrary :: Gen SugAgentState
  arbitrary = do
    randSugarMetab     <- choose (1, 4)
    randVision         <- choose (1, 6)
    randSugarEndowment <- choose (5, 25)
    randMaxAge         <- choose (60, 100)
    
    return SugAgentState {
      sugAgCoord        = (0, 0)
    , sugAgSugarMetab   = randSugarMetab
    , sugAgVision       = randVision
    , sugAgSugarLevel   = randSugarEndowment
    , sugAgMaxAge       = Just randMaxAge
    , sugAgAge          = 0
    , sugAgGender       = Male
    , sugAgFertAgeRange = (0, 0)
    , sugAgInitSugEndow = randSugarEndowment
    , sugAgChildren     = []
    , sugAgCultureTag   = []
    , sugAgTribe        = tagToTribe []
    , sugAgSpiceLevel   = randSugarEndowment
    , sugAgSpiceMetab   = randSugarMetab
    , sugAgInitSpiEndow = randSugarEndowment
    , sugAgBorrowed     = []
    , sugAgLent         = []
    , sugAgNetIncome    = 0
    , sugAgImmuneSystem = []
    , sugAgImSysGeno    = []
    , sugAgDiseases     = []
    }

agentTests :: RandomGen g 
           => g
           -> TestTree 
agentTests g = testGroup "Agent Tests"
            [ QC.testProperty "Starved To Death" $ prop_agent_starved g,
              QC.testProperty "Die Of Age" $ \a -> do
                                                      age <- choose (60, 100)
                                                      return $ prop_agent_dieOfAge g a age
            ] --, QC.testProperty "Metabolism" $ prop_agent_metabolism g]

prop_agent_starved :: RandomGen g 
                   => g
                   -> SugAgentState
                   -> Double
                   -> Bool
prop_agent_starved g0 asInit sugLvl 
    = starved == (sugLvl <= 0) &&
      asUnchanged &&
      absStateUnchanged &&
      envUnchanged
  where
    as0 = asInit { sugAgSugarLevel = sugLvl }
    absState0 = defaultAbsState
    env0      = emptyEnvironment

    (starved, as', absState', env', _) = runAgentMonad (starvedToDeath mkSugarScapeScenario) as0 absState0 env0 g0
    asUnchanged       = as0 == as'
    absStateUnchanged = absState0 == absState'
    envUnchanged      = env0 == env'

prop_agent_dieOfAge :: RandomGen g 
                    => g
                    -> SugAgentState
                    -> Int
                    -> Bool
prop_agent_dieOfAge g0 asInit age 
    = died == (age >= asMaxAge) &&
      asUnchanged &&
      absStateUnchanged &&
      envUnchanged
  where
    asMaxAge = fromJust $ sugAgMaxAge asInit

    as0 = asInit { sugAgAge = age }
    absState0 = defaultAbsState
    env0      = emptyEnvironment

    (died, as', absState', env', _) = runAgentMonad dieOfAge as0 absState0 env0 g0
    asUnchanged       = as0 == as'
    absStateUnchanged = absState0 == absState'
    envUnchanged      = env0 == env'

emptyEnvironment :: SugEnvironment
emptyEnvironment = createDiscrete2d (0, 0) moore WrapBoth []
