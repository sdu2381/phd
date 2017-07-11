module Segregation.SegregationInit (
    createSegregation
  ) where

import Segregation.SegregationModel
import Segregation.SegregationAgent

import FrABS.Agent.Agent
import FrABS.Env.Environment

import FRP.Yampa

import System.Random

createSegregation :: (Int, Int) -> IO ([SegAgentDef], SegEnvironment)
createSegregation limits@(x,y) =  
    do
        let coords = [ (xCoord, yCoord) | xCoord <- [0..x-1], yCoord <- [0..y-1] ]
        (as, envCells) <- populateEnv coords
        rng <- newStdGen
        let env = createEnvironment
                              Nothing
                              limits
                              moore
                              WrapBoth
                              envCells
                              rng
                              Nothing
        return (as, env)

populateEnv :: [(Int, Int)] -> IO ([SegAgentDef], [(EnvCoord, SegEnvCell)])
populateEnv coords = foldr populateEnvAux (return ([], [])) coords

populateEnvAux :: (Int, Int)
                    -> IO ([SegAgentDef], [(EnvCoord, SegEnvCell)])
                    -> IO ([SegAgentDef], [(EnvCoord, SegEnvCell)])
populateEnvAux coord accIO = 
    do
        (accAs, accCells) <- accIO

        let agentId = length accAs

        s <- randomAgentState
        rng <- newStdGen

        let a = AgentDef { adId = agentId,
                            adState = s,
                            adEnvPos = coord,
                            adInitMessages = NoEvent,
                            adConversation = Nothing,
                            adBeh = segAgentBehaviour,
                            adRng = rng }

        let emptyCell = (coord, Nothing)
        let occupiedCell = (coord, Just (segParty s))

        r <- getStdRandom (randomR(0.0, 1.0))
        if r < density then
            return ((a : accAs), occupiedCell : accCells)
            else
                return (accAs, emptyCell : accCells)

randomAgentState :: IO SegAgentState
randomAgentState = 
    do
        r <- getStdRandom (randomR(0.0, 1.0))
        let isRed = (r <= redGreenDist)

        let s = if isRed then
                    Red
                    else
                        Green

        return SegAgentState {
                segParty = s,
                segSimilarityWanted = similarityWanted,
                segSatisfactionLevel = 0.0 }