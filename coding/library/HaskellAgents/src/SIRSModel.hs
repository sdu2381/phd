module SIRSModel where

import Control.Monad.STM

import System.Random

import qualified HaskellAgents as Agent

data SIRSState = Susceptible | Infected | Recovered deriving (Eq, Show)
data SIRSMsg = Contact SIRSState

data SIRSAgentState = SIRSAgentState {
    sirState :: SIRSState,
    timeInState :: Double,
    rng :: StdGen
} deriving (Show)

type SIRSEnvironment = ()
type SIRSAgent = Agent.Agent SIRSMsg SIRSAgentState SIRSEnvironment
type SIRSMsgHandler = Agent.MsgHandler SIRSMsg SIRSAgentState SIRSEnvironment
type SIRSUpdtHandler = Agent.UpdateHandler SIRSMsg SIRSAgentState SIRSEnvironment

infectedDuration :: Double
infectedDuration = 3.0

immuneDuration :: Double
immuneDuration = 3.0

infectionProbability :: Double
infectionProbability = 1.0

is :: SIRSAgent -> SIRSState -> Bool
is a ss = (sirState s) == ss
    where
        s = Agent.state a


sirsMsgHandler :: SIRSMsgHandler
-- MESSAGE-CASE: Contact with Infected -> infect with given probability if agent is susceptibel
sirsMsgHandler a (Contact Infected) _               -- NOTE: ignore sender
    | is a Susceptible = return (infectAgent a)
    | otherwise = return a

-- MESSAGE-CASE: Contact with Recovered or Susceptible -> nothing happens
sirsMsgHandler a (Contact _) _ = return a           -- NOTE: ignore sender

sirsUpdtHandler :: SIRSUpdtHandler
sirsUpdtHandler a dt
    | is a Susceptible = return a
    | is a Infected = handleInfectedAgent a dt
    | is a Recovered = return (handleRecoveredAgent a dt)

infectAgent :: SIRSAgent -> SIRSAgent
infectAgent a
    | infect = Agent.updateState a (\sOld -> sOld { sirState = Infected, timeInState = 0.0, rng = g' } )
    | otherwise = Agent.updateState a (\sOld -> sOld { rng = g' } )
    where
        g = (rng (Agent.state a))
        (infect, g') = randomThresh g infectionProbability

handleInfectedAgent :: SIRSAgent -> Double -> STM SIRSAgent
handleInfectedAgent a dt = if t' >= infectedDuration then
                                return recoveredAgent           -- NOTE: agent has just recovered, don't send infection-contact to others
                                else
                                    randomContact gettingBetterAgent

    where
        t = (timeInState (Agent.state a))
        t' = t + dt
        recoveredAgent = Agent.updateState a (\sOld -> sOld { sirState = Recovered, timeInState = 0.0 } )
        gettingBetterAgent = Agent.updateState a (\sOld -> sOld { timeInState = t' } )

handleRecoveredAgent :: SIRSAgent -> Double -> SIRSAgent
handleRecoveredAgent a dt = if t' >= immuneDuration then
                                susceptibleAgent
                                else
                                    immuneReducedAgent
    where
        t = (timeInState (Agent.state a))
        t' = t + dt
        susceptibleAgent = Agent.updateState a (\sOld -> sOld { sirState = Susceptible, timeInState = 0.0 } )
        immuneReducedAgent = Agent.updateState a (\sOld -> sOld { timeInState = t' } )


randomContact :: SIRSAgent -> STM SIRSAgent
randomContact a = do
                    Agent.sendMsg a (Contact Infected) randAgentId
                    return (Agent.updateState a (\sOld -> sOld { rng = g' } ))
    where
        s = Agent.state a
        g = rng s
        nIds = Agent.neighbourIds a
        nsCount = length nIds
        (randIdx, g') = randomR(0, nsCount-1) g
        randAgentId = nIds !! randIdx

createRandomSIRSAgents :: StdGen -> Int -> Double -> STM ([SIRSAgent], StdGen)
createRandomSIRSAgents gInit n p = do
                                    let (randStates, g') = createRandomStates gInit n p
                                    as <- mapM (\idx -> Agent.createAgent idx (randStates !! idx) sirsMsgHandler sirsUpdtHandler) [0..n-1]
                                    let anp = Agent.agentsToNeighbourPair as
                                    -- NOTE: filter self
                                    let as' = map (\a -> Agent.addNeighbours a (filter (\(aid, _) -> aid /= (Agent.agentId a)) anp)) as
                                    return (as', g')
                                      where
                                        createRandomStates :: StdGen -> Int -> Double -> ([SIRSAgentState], StdGen)
                                        createRandomStates g 0 p = ([], g)
                                        createRandomStates g n p = (rands, g'')
                                            where
                                              (randState, g') = randomAgentState g p
                                              (ras, g'') = createRandomStates g' (n-1) p
                                              rands = randState : ras
randomAgentState :: StdGen -> Double -> (SIRSAgentState, StdGen)
randomAgentState g p = (SIRSAgentState{ sirState = s, timeInState = 0.0, rng = g'' }, g')
    where
        (isInfected, g') = randomThresh g p
        (g'', _) = split g'
        s = if isInfected then
                Infected
                else
                    Susceptible

randomThresh :: StdGen -> Double -> (Bool, StdGen)
randomThresh g p = (flag, g')
    where
        (thresh, g') = randomR(0.0, 1.0) g
        flag = thresh <= p



--------------------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE MODEL
--------------------------------------------------------------------------------------------------------------------------------------------------
stepSIRS :: IO ()
stepSIRS = do
        --hSetBuffering stdin NoBuffering
        let dt = 1.0
        let agentCount = 10
        let initInfectionProb = 0.2
        let rngSeed = 42
        let steps = 10
        let g = mkStdGen rngSeed
        -- NOTE: need atomically as well, although nothing has been written yet. primarily to change into the IO - Monad
        (as, g') <- atomically $ createRandomSIRSAgents g agentCount initInfectionProb
        putStrLn "Initial:"
        printAgents as
        -- NOTE: this works for now when NOT using parallelism
        --  (as', e') <- atomically $ Agents.stepSimulation as Nothing dt steps
        --Agents.runSimulation as Nothing (outputStep dt)
        as' <- atomically $ Agent.initStepSimulation as Nothing
        runSteps as' 6 dt
        return ()

runSteps :: [SIRSAgent] -> Int -> Double -> IO [SIRSAgent]
runSteps as 0 dt = return as
runSteps as n dt = do
                    (as', _) <- atomically $ Agent.advanceSimulation as dt
                    putStrLn ("Step " ++ (show n) ++ ":")
                    printAgents as'
                    runSteps as' (n-1) dt

outputStep :: (Show e) => Double -> (([SIRSAgent], Maybe e) -> IO (Bool, Double))
outputStep dt (as, e) = do
                            c <- getLine
                            putStrLn c
                            putStrLn (show e)
                            printAgents as
                            return (True, dt)

printAgents :: [SIRSAgent] -> IO ()
printAgents as = do
                    mapM (putStrLn . show . Agent.state) as
                    return ()

--------------------------------------------------------------------------------------------------------------------------------------------------