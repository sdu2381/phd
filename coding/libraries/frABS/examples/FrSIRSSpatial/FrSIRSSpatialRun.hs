module FrSIRSSpatial.FrSIRSSpatialRun ( 
    runFrSIRSSpatialWithRendering,
    runFrSIRSSpatialStepsAndRender,
    runFrSIRSSpatialStepsAndWriteToFile,
    runFrSIRSSpatialReplicationsAndWriteToFile
  ) where

import FrSIRSSpatial.FrSIRSSpatialInit
import FrSIRSSpatial.FrSIRSSpatialModel
import FrSIRSSpatial.FrSIRSSpatialRenderer as Renderer
import Utils.Utils

import FrABS.Agent.Agent
import FrABS.Simulation.Simulation
import FrABS.Simulation.SimulationUtils
import FrABS.Rendering.GlossSimulator

import Text.Printf
import System.IO
import Debug.Trace 

winSize = (800, 800)
winTitle = "FrSIRS Spatial"

updateStrat = Parallel
shuffleAgents = False

rngSeed = 42

agentDimensions = (31, 31)
frequency = 0

samplingTimeDelta = 0.1
steps = 140
replications = 10

runFrSIRSSpatialWithRendering :: IO ()
runFrSIRSSpatialWithRendering =
    do
        _ <- initRng rngSeed
        -- (initAdefs, initEnv) <- createFrSIRSSpatialRandomInfected agentDimensions initialInfectionProb
        (initAdefs, initEnv) <- createFrSIRSSpatialSingleInfected agentDimensions
        
        params <- initSimParams updateStrat Nothing shuffleAgents

        simulateAndRender initAdefs
                            initEnv
                            params
                            samplingTimeDelta
                            frequency
                            winTitle
                            winSize
                            Renderer.renderFrame
                            (Just (\_ asenv -> printAgentDynamics asenv))

runFrSIRSSpatialStepsAndRender :: IO ()
runFrSIRSSpatialStepsAndRender =
    do
        _ <- initRng rngSeed
        -- (initAdefs, initEnv) <- createFrSIRSSpatialRandomInfected agentDimensions initialInfectionProb
        (initAdefs, initEnv) <- createFrSIRSSpatialSingleInfected agentDimensions
        params <- initSimParams updateStrat Nothing shuffleAgents

        simulateStepsAndRender initAdefs
                            initEnv
                            params
                            samplingTimeDelta
                            steps
                            winTitle
                            winSize
                            Renderer.renderFrame

runFrSIRSSpatialStepsAndWriteToFile :: IO ()
runFrSIRSSpatialStepsAndWriteToFile =
    do
        _ <- initRng rngSeed
        (initAdefs, initEnv) <- createFrSIRSSpatialRandomInfected agentDimensions initialInfectionProb
        params <- initSimParams updateStrat Nothing shuffleAgents

        let asenv = processSteps initAdefs initEnv params samplingTimeDelta steps
        let dynamics = map agentsToDynamics asenv
        let fileName = "frSIRSSpatialDynamics_" 
                        ++ show agentDimensions ++ "agents_" 
                        ++ show steps ++ "steps_" 
                        ++ show samplingTimeDelta ++ "_dt.m"

        writeSirsDynamicsFile fileName steps samplingTimeDelta 0 dynamics

runFrSIRSSpatialReplicationsAndWriteToFile :: IO ()
runFrSIRSSpatialReplicationsAndWriteToFile =
    do
        _ <- initRng rngSeed
        (initAdefs, initEnv) <- createFrSIRSSpatialRandomInfected agentDimensions initialInfectionProb
        params <- initSimParams updateStrat Nothing shuffleAgents

        let assenv = runReplications initAdefs initEnv params samplingTimeDelta steps replications
        let replicationDynamics = map calculateSingleReplicationDynamic assenv
        let dynamics = sirsDynamicsReplMean replicationDynamics

        let fileName = "frSIRSSpatialDynamics_" 
                        ++ show agentDimensions ++ "agents_" 
                        ++ show steps ++ "steps_" 
                        ++ show samplingTimeDelta ++ "_dt_" 
                        ++ (show replications) ++ "_replications.m"

        writeSirsDynamicsFile fileName steps samplingTimeDelta replications dynamics

-------------------------------------------------------------------------------
-- UTILS
-------------------------------------------------------------------------------
agentsToDynamics = (calculateDynamics . fst)
printAgentDynamics = (putStrLn . sirsDynamicToString . agentsToDynamics)

calculateDynamics :: [FrSIRSSpatialAgentOut] -> (Double, Double, Double)
calculateDynamics aos = (susceptibleRatio, infectedRatio, recoveredRatio)
    where
        susceptibleCount = length $ filter ((Susceptible==) . aoState) aos
        infectedCount = length $ filter ((Infected==) . aoState) aos
        recoveredCount = length $ filter ((Recovered==) . aoState) aos

        totalCount = fromIntegral $ susceptibleCount + infectedCount + recoveredCount :: Double

        susceptibleRatio = fromIntegral susceptibleCount / totalCount
        infectedRatio = fromIntegral infectedCount / totalCount 
        recoveredRatio = fromIntegral recoveredCount / totalCount

calculateSingleReplicationDynamic :: [([FrSIRSSpatialAgentOut], FrSIRSSpatialEnvironment)] -> [(Double, Double, Double)]
calculateSingleReplicationDynamic  aoss = map (calculateDynamics . fst) aoss
