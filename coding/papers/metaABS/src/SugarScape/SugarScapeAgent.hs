{-# LANGUAGE Arrows #-}
module SugarScape.SugarScapeAgent where

-- Project-internal import first
import SugarScape.SugarScapeModel
import FrABS.Env.Environment
import FrABS.Agent.Agent

-- Project-specific libraries follow
import FRP.Yampa

-- System imports then
import Data.Maybe
import Data.List

-- debugging imports finally, to be easily removed in final version
import Debug.Trace
import System.Random

------------------------------------------------------------------------------------------------------------------------
-- AGENT-BEHAVIOUR
------------------------------------------------------------------------------------------------------------------------
cellOccupied :: SugarScapeEnvCell -> Bool
cellOccupied cell = isJust $ sugEnvOccupied cell

cellUnoccupied :: SugarScapeEnvCell -> Bool
cellUnoccupied = not . cellOccupied

agentDies :: SugarScapeAgentOut -> SugarScapeAgentOut
agentDies = unoccupyPosition . kill

agentAction :: SugarScapeAgentOut -> SugarScapeAgentOut
agentAction a
    | starvedToDeath agentAfterHarvest = agentDies agentAfterHarvest
    | otherwise = agentAfterHarvest
    where
        agentAfterHarvest = agentMetabolism $ agentCollecting a

unoccupyPosition ::  SugarScapeAgentOut -> SugarScapeAgentOut
unoccupyPosition a = a { aoEnv = env' }
    where
        env = aoEnv a

        currentAgentPosition = aoEnvPos a
        currentAgentCell = cellAt env currentAgentPosition
        currentAgentCellUnoccupied = currentAgentCell { sugEnvOccupied = Nothing }

        env' = changeCellAt env currentAgentPosition currentAgentCellUnoccupied

starvedToDeath :: SugarScapeAgentOut -> Bool
starvedToDeath a = sugAgSugar s <= 0
    where
        s = aoState a

agentMetabolism :: SugarScapeAgentOut -> SugarScapeAgentOut
agentMetabolism a = updateState
                            a
                            (\s -> s {
                                sugAgSugar =
                                    max
                                        0
                                        ((sugAgSugar s) - (sugAgMetabolism s))})

agentCollecting :: SugarScapeAgentOut -> SugarScapeAgentOut
agentCollecting a
    | null unoccupiedCells = a
    | otherwise = aHarvested
    where
        cellsInSight = agentLookout a
        unoccupiedCells = filter (cellUnoccupied . snd) cellsInSight

        bestCells = selectBestCells (aoEnvPos a) unoccupiedCells
        -- NOTE: can return equally good cells, do random selection
        (a', cellInfo) = agentPickRandom a bestCells

        aHarvested = agentMoveAndHarvestCell a' cellInfo

agentMoveAndHarvestCell :: SugarScapeAgentOut -> (EnvCoord, SugarScapeEnvCell) -> SugarScapeAgentOut
agentMoveAndHarvestCell a (cellCoord, cell) = updateState a'' (\s -> s { sugAgSugar = newSugarLevelAgent })
    where
        sugarLevelCell = sugEnvSugarLevel cell
        sugarLevelAgent = sugAgSugar $ aoState a
        newSugarLevelAgent = (sugarLevelCell + sugarLevelAgent)

        a' = unoccupyPosition a
        env = aoEnv a'

        agentMetabolism = sugAgMetabolism $ aoState a
        polutionIncByMeta =  agentMetabolism * polutionMetabolismFactor
        polutionIncByHarvest = sugarLevelCell * polutionHarvestFactor
        newPolutionLevel = polutionIncByMeta + polutionIncByHarvest + sugEnvPolutionLevel cell

        cellHarvestedAndOccupied = cell {
                sugEnvSugarLevel = 0.0,
                sugEnvOccupied = Just (aoId a),
                sugEnvPolutionLevel = newPolutionLevel
                }
        env' = changeCellAt env cellCoord cellHarvestedAndOccupied

        a'' = a' { aoEnvPos = cellCoord, aoEnv = env' }


selectBestCells :: EnvCoord -> [(EnvCoord, SugarScapeEnvCell)] -> [(EnvCoord, SugarScapeEnvCell)]
selectBestCells refCoord cs = bestShortestDistanceCells
    where
        measureFunc = bestMeasureSugarPolutionRatio

        cellsSortedByMeasure = sortBy (\c1 c2 -> compare (measureFunc $ snd c2) (measureFunc $ snd c1)) cs
        bestCellMeasure = measureFunc $ snd $ head cellsSortedByMeasure
        bestCells = filter ((==bestCellMeasure) . measureFunc . snd) cellsSortedByMeasure

        shortestDistanceBestCells = sortBy (\c1 c2 -> compare (distance refCoord (fst c1)) (distance refCoord (fst c2))) bestCells
        shortestDistance = distance refCoord (fst $ head shortestDistanceBestCells)
        bestShortestDistanceCells = filter ((==shortestDistance) . (distance refCoord) . fst) shortestDistanceBestCells

        bestMeasureSugarLevel :: SugarScapeEnvCell -> Double
        bestMeasureSugarLevel c = sugEnvSugarLevel c

        bestMeasureSugarPolutionRatio :: SugarScapeEnvCell -> Double
        bestMeasureSugarPolutionRatio c = sugLvl / (1 + polLvl)
            where
                sugLvl = sugEnvSugarLevel c
                polLvl = sugEnvPolutionLevel c

-- TODO: think about moving this to the general Agent.hs: introduce a Maybe StdGen, but then: don't we loose reasoning abilities?
agentPickRandom :: SugarScapeAgentOut -> [a] -> (SugarScapeAgentOut, a)
agentPickRandom a all@(x:xs)
    | null xs = (a, x)
    | otherwise = (a', randElem)
    where
        g = sugAgRng $ aoState a
        cellCount = length all
        (randIdx, g') = randomR (0, cellCount - 1) g
        randElem = all !! randIdx
        a' = updateState a (\s -> s { sugAgRng = g' } )

agentLookout :: SugarScapeAgentOut -> [(EnvCoord, SugarScapeEnvCell)]
agentLookout a = zip visionCoordsWrapped visionCells
    where
        env = aoEnv a
        aPos = aoEnvPos a
        n = envNeighbourhood env
        vis = sugAgVision $ aoState a

        -- TODO: put this logic into environment.hs
        visionCoordsDeltas = foldr (\v acc -> acc ++ (neighbourhoodScale n v)) [] [1 .. vis]
        visionCoords = neighbourhoodOf aPos visionCoordsDeltas
        visionCoordsWrapped = wrapCells (envLimits env) (envWrapping env) visionCoords
        visionCells = cellsAt env visionCoordsWrapped

agentAgeing :: SugarScapeAgentOut -> Double -> SugarScapeAgentOut
agentAgeing a age
    | diedFromAge a age = agentDies $ birthNewAgent a
    | otherwise = agentAction a

birthNewAgent :: SugarScapeAgentOut -> SugarScapeAgentOut
birthNewAgent a = createAgent a newAgentDef
    where
        newAgentId = aoId a                                 -- NOTE: we keep the old id
        (newAgentCoord, a') = findUnoccpiedRandomPosition a
        oldAgentRng = sugAgRng $ aoState a'
        (newAgentDef, _) = randomAgent (newAgentId, newAgentCoord) oldAgentRng

        findUnoccpiedRandomPosition :: SugarScapeAgentOut -> (EnvCoord, SugarScapeAgentOut)
        findUnoccpiedRandomPosition a
            | cellOccupied c = findUnoccpiedRandomPosition a'
            | otherwise = (coord, a')
            where
                g = sugAgRng $ aoState a
                env = aoEnv a
                (c, coord, g') = randomCell g env
                a' = updateState a (\s -> s { sugAgRng = g' })

diedFromAge :: SugarScapeAgentOut -> Double -> Bool
diedFromAge a age = age >= (sugAgMaxAge $ aoState a)

randomAgent :: (AgentId, EnvCoord) -> StdGen -> (SugarScapeAgentDef, StdGen)
randomAgent (agentId, coord) g0 = (adef, g5)
    where
        (randMeta, g1) = randomR metabolismRange g0
        (randVision, g2) = randomR visionRange g1
        (randEnd, g3) = randomR sugarEndowmentRange g2
        (randMaxAge, g4) = randomR ageRange g3
        (rng, g5) = split g4

        s = SugarScapeAgentState {
            sugAgMetabolism = randMeta,
            sugAgVision = randVision,
            sugAgSugar = randEnd,
            sugAgMaxAge = randMaxAge,
            sugAgRng = rng
        }

        adef = AgentDef {
           adId = agentId,
           adState = s,
           adEnvPos = coord,
           adInitMessages = NoEvent,
           adBeh = sugarScapeAgentBehaviour }

sugarScapeAgentBehaviour :: SugarScapeAgentBehaviour
sugarScapeAgentBehaviour = proc ain ->
    do
        let a = agentOutFromIn ain
        age <- time -< 0
        returnA -< agentAgeing a age
------------------------------------------------------------------------------------------------------------------------