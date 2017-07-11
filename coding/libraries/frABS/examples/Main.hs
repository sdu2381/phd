module Main where

import AgentZero.Run
import Conversation.Run
import DoubleAuction.Run
import FrSIRSNetwork.Run
import FrSIRSSpatial.Run
import PolicyEffects.Run
import PrisonersDilemma.Run
import RecursiveABS.Run
import SIRS.Run
import Segregation.Run
import SugarScape.Run
import SysDynSIR.Run
import Wildfire.Run

{-
	TODOs
    - rename all files in examples: get rid of example name 
    - add FRP folder FrABS 
    - FrABS imports and re-exports all symbols => only need to include FrABS.FrABS 
    - PolicyEffects should use its own replicator for the environment
    - refactor SIRS: use time
    - implement Prisoners Dilemma
    - the 2d-renderer are all the same: refactor into one
    - implement Heroes & Cowards
        - use-case for continuous 2d-environment: implement Heroes & Cowards
        -> write Agend2DContinuous
            - continuous 2d env: just add a map of agentids with their positions to the env, agents can then update their continuous position (needs to remove itself when killed). problem: environment needs to know about agentid. but do we really need that? it would save us exchanging messages.
            - basically it would suffice to add another field: posCont and make the other posDisc. or can we distinguish by types the position: any num type
            - maybe distinguish between discrete agent and continuous agent
            - distinguish between cont and disc env

    - clean-up
        - imports: no unused imports
        - warnings: compilation with -w must show no warnings at all
        - lint: must be clear of warnings

    - comment haskell code
        
    - performance?
-}

main :: IO ()
main = runAgentZeroWithRendering

    -- runFrSIRSNetworkStepsAndWriteToFile -- runFrSIRSNetworkWithRendering -- runFrSIRSNetworkReplicationsAndWriteToFile
    -- runSysDynSIRStepsAndWriteToFile
    -- runFrSIRSSpatialWithRendering -- runFrSIRSSpatialStepsAndPrint -- runFrSIRSSpatialStepsAndWriteToFile
    -- runDoubleAuctionSteps
    -- runSIRSWithRendering
    -- runPDWithRendering
    -- runWildfireWithRendering
    -- runAgentZeroWithRendering
    -- runSugarScapeWithRendering
    -- runConversationSteps
    -- runMetaABSStepsAndPrint
    -- runSegWithRendering

{-
import System.IO
import System.IO.Unsafe
import System.Random

import Control.Monad
import Control.Concurrent
import Control.Monad.STM
import Control.Concurrent.STM.TVar
import Control.Concurrent.STM.Stats

main :: IO ()
main = do
    hSetBuffering stdout NoBuffering

    var <- newTVarIO 0
    mapM (\i -> forkIO $
        do 
            threadId <- myThreadId
            forever $
                do
                    randDelay <- getStdRandom (randomR (100000,500000))
                    threadDelay randDelay

                    -- value <- atomically $ incrementAtomically var
                    --value <- trackSTM $ incrementAtomically var
                    let value = incrementAtomicallyUnsafe var

                    putStrLn ("Thread " ++ (show threadId) ++ " produced value: " ++ (show value))
            ) [1..10]

    -- wait 10 seconds
    threadDelay 10000000

    value <- readTVarIO var
    putStrLn ("Main reads value: " ++ (show value))

    --dumpSTMStats

incrementAtomically :: TVar Int -> STM Int
incrementAtomically var = 
    do
        value <- readTVar var
        writeTVar var (value + 1)
        return value

incrementAtomicallyUnsafe :: TVar Int -> Int
incrementAtomicallyUnsafe = unsafePerformIO  . atomically . incrementAtomically
-}