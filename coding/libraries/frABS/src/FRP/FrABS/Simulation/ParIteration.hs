module FRP.FrABS.Simulation.ParIteration (
    simulatePar
  ) where

import qualified Data.Map as Map
import Data.Maybe
import Control.Concurrent.STM.TVar

import FRP.Yampa
import FRP.Yampa.InternalCore

import FRP.FrABS.Agent.Agent
import FRP.FrABS.Simulation.Init
import FRP.FrABS.Simulation.Internal
import FRP.FrABS.Simulation.Common


-- | Steps the simulation using a parallel update-strategy. 
-- Conversations and Recursive Simulation is NOT possible using this strategy.
-- In this strategy each agents SF is run after the same time, actions 
-- are only seen in the next step. This makes
-- this strategy work basically as a map (as opposed to fold in the sequential case).
-- Although the agents make the move at the same time, when shuffling them, 
-- the order of collecting and distributing the messages makes a difference 
-- if model-semantics are relying on randomized message-ordering, 
-- then shuffling is required and has to be turned on in the params.
--
-- An agent which kills itself will still have all its output processed
-- meaning that newly created agents and sent messages are not discharged.
--
-- It is not possible to send messages to currently non-existing agents,
-- also not to agents which may exist in the future. Messages which
-- have as receiver a non-existing agent are discharged without any notice
-- (a minor exception is the sending of messages to newly spawned agents
-- within the iteration when they were created: although they are not running
-- yet, they are known already to the system and will run in the next step).

simulatePar :: SimulationParams e
                -> [AgentBehaviour s m e]
                -> [AgentIn s m e]
                -> e
                -> SF () ([AgentOut s m e], e)
simulatePar initParams initSfs initIns initEnv = SF { sfTF = tf0 }
    where
        tf0 _ = (tfCont, (initOuts, initEnv))
            where
                -- NOTE: to prevent undefined outputs we create outputs based on the initials
                initOuts = map agentOutFromIn initIns
                --initInputsWithEnv = addEnvToAins initEnv initAis
                tfCont = simulateParAux initParams initSfs initIns initEnv

        simulateParAux params sfs ins e = SF' tf
            where
                tf dt _ =  (tf', (outs, e'))
                    where
                         -- run the next step with the new sfs and inputs to get the sf-contintuations and their outputs
                        (sfs', outs, envs) = iterateAgents dt sfs ins e

                        -- using the callback to create the next inputs and allow changing of the SF-collection
                        (sfs'', ins') = nextStep ins outs sfs'

                        (e', params') = collapseEnvironments dt params envs e 
                        
                        -- NOTE: shuffling may seem strange in parallel but this will ensure random message-distribution when required
                        (params'', sfsShuffled, insShuffled) = shuffleAgents params' sfs'' ins'
                        
                        tf' = simulateParAux params'' sfsShuffled insShuffled e'

        collapseEnvironments :: Double 
                                -> SimulationParams e 
                                -> [e] 
                                -> e 
                                -> (e, SimulationParams e)
        collapseEnvironments dt params allEnvs defaultEnv
            | isCollapsingEnv = runEnv dt params collapsedEnv 
            | otherwise = (defaultEnv, params)
            where
                isCollapsingEnv = isJust mayEnvCollapFun

                mayEnvCollapFun = simEnvCollapse params
                envCollapFun = fromJust mayEnvCollapFun

                collapsedEnv = envCollapFun allEnvs 

iterateAgents :: DTime 
                -> [AgentBehaviour s m e] 
                -> [AgentIn s m e] 
                -> e
                -> ([AgentBehaviour s m e], [AgentOut s m e], [e])
iterateAgents dt sfs ins e = unzip3 sfsOutsEnvs
    where
        sfsOutsEnvs = map (iterateAgentsAux e) (zip sfs ins)

        iterateAgentsAux :: e
                            -> (AgentBehaviour s m e, AgentIn s m e)
                            -> (AgentBehaviour s m e, AgentOut s m e, e)
        iterateAgentsAux e (sf, ain) = (sf', ao, e')
            where
                (sf', (ao, e')) = runAndFreezeSF sf (ain, e) dt

nextStep :: [AgentIn s m e]
            -> [AgentOut s m e]
            -> [AgentBehaviour s m e]
            -> ([AgentBehaviour s m e], [AgentIn s m e])
nextStep oldAgentIns newAgentOuts asfs = (asfs', newAgentIns')
    where
        (asfs', newAgentIns) = processAgents asfs oldAgentIns newAgentOuts
        newAgentIns' = distributeMessages newAgentIns newAgentOuts

        processAgents :: [AgentBehaviour s m e]
                            -> [AgentIn s m e]
                            -> [AgentOut s m e]
                            -> ([AgentBehaviour s m e], [AgentIn s m e])
        processAgents asfs oldIs newOs = foldr handleAgent ([], []) asfsIsOs
            where
                asfsIsOs = zip3 asfs oldIs newOs

                handleAgent :: (AgentBehaviour s m e, AgentIn s m e, AgentOut s m e)
                                -> ([AgentBehaviour s m e], [AgentIn s m e])
                                -> ([AgentBehaviour s m e], [AgentIn s m e])
                handleAgent a@(_, oldIn, newOut) acc = handleKillOrLiveAgent acc' a
                    where
                        idGen = aiIdGen oldIn
                        acc' = handleCreateAgents idGen newOut acc 

                handleKillOrLiveAgent :: ([AgentBehaviour s m e], [AgentIn s m e])
                                            -> (AgentBehaviour s m e, AgentIn s m e, AgentOut s m e)
                                            -> ([AgentBehaviour s m e], [AgentIn s m e])
                handleKillOrLiveAgent acc@(asfsAcc, ainsAcc) (sf, oldIn, newOut)
                    | killAgent = acc
                    | otherwise = (sf : asfsAcc, newIn : ainsAcc) 
                    where
                        killAgent = isEvent $ aoKill newOut
                        newIn = newAgentIn oldIn newOut

handleCreateAgents :: TVar Int
                        -> AgentOut s m e
                        -> ([AgentBehaviour s m e], [AgentIn s m e])
                        -> ([AgentBehaviour s m e], [AgentIn s m e])
handleCreateAgents idGen ao acc@(asfsAcc, ainsAcc) 
    | hasCreateAgents = (asfsAcc ++ newSfs, ainsAcc ++ newAis)
    | otherwise = acc
    where
        newAgentDefsEvt = aoCreate ao
        hasCreateAgents = isEvent newAgentDefsEvt
        newAgentDefs = fromEvent newAgentDefsEvt
        newSfs = map adBeh newAgentDefs
        newAis = map (startingAgentInFromAgentDef idGen) newAgentDefs

distributeMessages :: [AgentIn s m e] -> [AgentOut s m e] -> [AgentIn s m e]
distributeMessages ains aouts = map (distributeMessagesAux allMsgs) ains
    where
        allMsgs = collectAllMessages aouts

        distributeMessagesAux :: Map.Map AgentId [AgentMessage m]
                                    -> AgentIn s m e
                                    -> AgentIn s m e
        distributeMessagesAux allMsgs ain = ain'
            where
                receiverId = aiId ain
                msgs = aiMessages ain -- NOTE: ain may have already messages, they would be overridden if not incorporating them

                mayReceiverMsgs = Map.lookup receiverId allMsgs
                msgsEvt = maybe msgs (\receiverMsgs -> mergeMessages (Event receiverMsgs) msgs) mayReceiverMsgs

                ain' = ain { aiMessages = msgsEvt }

collectAllMessages :: [AgentOut s m e] -> Map.Map AgentId [AgentMessage m]
collectAllMessages aos = foldr collectAllMessagesAux Map.empty aos
    where
        collectAllMessagesAux :: AgentOut s m e
                                    -> Map.Map AgentId [AgentMessage m]
                                    -> Map.Map AgentId [AgentMessage m]
        collectAllMessagesAux ao accMsgs 
            | isEvent msgsEvt = foldr collectAllMessagesAuxAux accMsgs (fromEvent msgsEvt)
            | otherwise = accMsgs
            where
                senderId = aoId ao
                msgsEvt = aoMessages ao

                collectAllMessagesAuxAux :: AgentMessage m
                                            -> Map.Map AgentId [AgentMessage m]
                                            -> Map.Map AgentId [AgentMessage m]
                collectAllMessagesAuxAux (receiverId, m) accMsgs = accMsgs'
                    where
                        msg = (senderId, m)
                        mayReceiverMsgs = Map.lookup receiverId accMsgs
                        newMsgs = maybe [msg] (\receiverMsgs -> (msg : receiverMsgs)) mayReceiverMsgs

                        -- NOTE: force evaluation of messages, will reduce memory-overhead EXTREMELY
                        accMsgs' = seq newMsgs (Map.insert receiverId newMsgs accMsgs)