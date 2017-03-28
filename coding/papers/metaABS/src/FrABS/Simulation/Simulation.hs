{-# LANGUAGE Arrows #-}
module FrABS.Simulation.Simulation where

-- Project-internal import first
import FrABS.Env.Environment
import FrABS.Simulation.SeqIteration
import FrABS.Simulation.ParIteration
import FrABS.Agent.Agent

-- Project-specific libraries follow
import FRP.Yampa
import FRP.Yampa.InternalCore

-- System imports then
import Data.Maybe
import Data.List

-- TODO: remove these imports
-- debugging imports finally, to be easily removed in final version
import Debug.Trace

----------------------------------------------------------------------------------------------------------------------
-- TODOs
----------------------------------------------------------------------------------------------------------------------
-- TODO: allow to be able to stop simulation when iteration.function returns True
-- TODO: sequential iteration should have the feature to shuffle agents randomly before iterating them

-- TODO: hide AgentIn and AgentOut same way as DTime is hidden, only generic state in/out

-- TODO create project structure according to put it on Hackage in september: tests, comments,...
-- TODO write unit-tests
-- TODO write QuickCheck tests

-- TODO STM FrABS using Dunai?
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
-- RUNNING SIMULATION WITH ITS OWN LOOP
----------------------------------------------------------------------------------------------------------------------
processIO :: [AgentDef s m ec]
                -> Environment ec
                -> Bool
                -> ([AgentOut s m ec] -> IO (Bool, Double))
                -> IO ()
processIO as env parStrategy outFunc = do
                                        hdl <- reactInit
                                                    (return ains)
                                                    (iter outFunc)
                                                    (process as parStrategy)
                                        FrABS.Simulation.Simulation.iterate hdl (1.0, Nothing)
                                        return ()
                                            where
                                                ains = createStartingAgentIn as env

iterate :: ReactHandle a b
            -> (DTime, Maybe a)
            -> IO Bool
iterate hdl (dt, input) = do
                            cont <- react hdl (1.0, Nothing)
                            if cont then
                                FrABS.Simulation.Simulation.iterate hdl (dt, input)
                                    else
                                        return False

-- NOTE: don't care about a, we don't use it anyway
iter :: ([AgentOut s m ec]
            -> IO (Bool, Double))
            -> ReactHandle a [AgentOut s m ec]
            -> Bool
            -> [AgentOut s m ec]
            -> IO Bool
iter outFunc hdl _ out = do
                            (cont, dt) <- outFunc out
                            return cont
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
-- RUNNING SIMULATION FROM AN OUTER LOOP
----------------------------------------------------------------------------------------------------------------------
-- NOTE: don't care about a, we don't use it anyway
processIOInit :: [AgentDef s m ec]
                    -> Environment ec
                    -> Bool
                    -> (ReactHandle [AgentIn s m ec] [AgentOut s m ec]
                            -> Bool
                            -> [AgentOut s m ec]
                            -> IO Bool)
                    -> IO (ReactHandle [AgentIn s m ec] [AgentOut s m ec])
processIOInit as env parStrategy iterFunc = reactInit
                                                (return ains)
                                                iterFunc
                                                (process as parStrategy)
    where
        ains = createStartingAgentIn as env
----------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------
-- CALCULATING A FIXED NUMBER OF STEPS OF THE SIMULATION
----------------------------------------------------------------------------------------------------------------------
{- NOTE: to run Yampa in a pure-functional way use embed -}
processSteps :: [AgentDef s m ec]
                    -> Environment ec
                    -> Bool
                    -> Double
                    -> Int
                    -> [[AgentOut s m ec]]
processSteps as env parStrategy dt steps = embed
                                            (process as parStrategy)
                                            (ains, sts)
    where
        -- NOTE: again haskells laziness put to use: take steps items from the infinite list of sampling-times
        sts = replicate steps (dt, Nothing)
        ains = createStartingAgentIn as env


----------------------------------------------------------------------------------------------------------------------
process :: [AgentDef s m ec] -> Bool -> SF [AgentIn s m ec] [AgentOut s m ec]
process as parStrategy = iterationStrategy asfs parStrategy
    where
        asfs = map adBeh as

iterationStrategy :: [SF (AgentIn s m ec) (AgentOut s m ec)] -> Bool -> SF [AgentIn s m ec] [AgentOut s m ec]
iterationStrategy asfs parStrategy
    | parStrategy = runParSF asfs parCallback
    | otherwise = runSeqSF asfs seqCallback seqCallbackIteration

simulate :: [AgentIn s m ec]
                  -> [SF (AgentIn s m ec) (AgentOut s m ec)]
                  -> Bool
                  -> Double
                  -> Int
                  -> [[AgentOut s m ec]]
simulate ains asfs parStrategy dt steps = embed
                                                  sfStrat
                                                  (ains, sts)
    where
        sts = replicate steps (dt, Nothing)
        sfStrat = iterationStrategy asfs parStrategy
----------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------
-- PARALLEL STRATEGY
----------------------------------------------------------------------------------------------------------------------
-- TODO: collapse all environments into one - collapsing is specific to the model!!
-- TODO run the behaviour of the resulting environment
-- TODO distribute the resulting env to all agentins
parCallback :: [AgentIn s m ec]
                -> [AgentOut s m ec]
                -> [AgentBehaviour s m ec]
                -> ([AgentBehaviour s m ec], [AgentIn s m ec])
parCallback oldAgentIns newAgentOuts asfs = (asfs', newAgentIns0)
    where
        (asfs', newAgentIns) = processAgents asfs oldAgentIns newAgentOuts
        newAgentIns0 = distributeMessages newAgentIns newAgentOuts

        processAgents :: [AgentBehaviour s m ec]
                            -> [AgentIn s m ec]
                            -> [AgentOut s m ec]
                            -> ([AgentBehaviour s m ec], [AgentIn s m ec])
        processAgents asfs oldIs newOs = foldr (\a acc -> handleAgent acc a ) ([], []) asfsWithIsOs
            where
                asfsWithIsOs = zip3 asfs oldIs newOs

                handleAgent :: ([AgentBehaviour s m ec], [AgentIn s m ec])
                                -> (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
                                -> ([AgentBehaviour s m ec], [AgentIn s m ec])
                handleAgent acc a@(sf, oldIn, newOut) = handleKillOrLiveAgent acc' a
                    where
                        acc' = handleCreateAgents acc newOut

                handleKillOrLiveAgent :: ([AgentBehaviour s m ec], [AgentIn s m ec])
                                            -> (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
                                            -> ([AgentBehaviour s m ec], [AgentIn s m ec])
                handleKillOrLiveAgent acc@(asfsAcc, ainsAcc) (sf, oldIn, newOut)
                    | kill = acc
                    | live = (asfsAcc ++ [sf], ainsAcc ++ [newIn])
                    where
                        kill = isEvent $ aoKill newOut
                        live = not kill
                        newIn = oldIn { aiStart = NoEvent,
                                        aiState = (aoState newOut),
                                        aiMessages = NoEvent }
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
-- SEQUENTIAL STRATEGY
----------------------------------------------------------------------------------------------------------------------
-- TODO: collapse all environments into one - collapsing is specific to the model!!
-- TODO run the behaviour of the resulting environment
-- TODO distribute the resulting env to all agentins
seqCallbackIteration :: [AgentOut s m ec] -> ([AgentBehaviour s m ec], [AgentIn s m ec])
seqCallbackIteration aouts = (newSfs, newSfsIns')
    where
        -- NOTE: messages of this agent are ALWAYS distributed, whether it is killed or not
        (newSfs, newSfsIns) = foldl handleCreateAgents ([], []) aouts
        -- NOTE: distribute messages to newly created agents as well
        newSfsIns' = distributeMessages newSfsIns aouts

seqCallback :: ([AgentIn s m ec], [AgentBehaviour s m ec])
                -> (AgentBehaviour s m ec)
                -> (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
                -> ([AgentIn s m ec],
                    Maybe (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec))
seqCallback (otherIns, otherSfs) oldSf a@(sf, oldIn, newOut)
    | doRecursion = seqCallbackRec otherIns otherSfs oldSf (sf, recIn, newOut)
    | otherwise = handleAgent otherIns (sf, unRecIn, newOut)
    where
        -- NOTE: first layer of recursion: calling simulate within a simulation
        -- NOTE: at this level we are determining how many levels of recursion we run: at the moment, we stop after the first level
        doRecursion = if (isEvent (aiRec oldIn)) then
                        False   -- this is recursion-level 1 (0 is the initial level), stop here, can be replaced by counter in the future
                        else
                            isEvent $ aoRec newOut      -- this is recursion-level 0 (initial level), do recursion only if the agent requests to do so

        -- NOTE: need to handle inputs different based upon whether we are doing
        recIn = if (isEvent $ aiRec oldIn) then
                    oldIn -- this is recursion level 1 => will do normal agent-handling and feed past outputs to the agent so it can select the best
                    else
                        oldIn { aiRec = Event [] } -- this is recursion level 0 => start with empty past outputs

        -- NOTE: need to stop recursion
        unRecIn = oldIn { aiRec = NoEvent }

        -- NOTE: second layer of recursion: this allows the agent to simulate an arbitrary number of AgentOuts
        seqCallbackRec :: [AgentIn s m ec]
                           -> [AgentBehaviour s m ec]
                           -> (AgentBehaviour s m ec)
                           -> (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
                           -> ([AgentIn s m ec],
                               Maybe (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec))
        seqCallbackRec otherIns otherSfs oldSf a@(sf, recIn, newOut)
            | isEvent $ aoRec newOut = handleRecursion otherIns otherSfs oldSf (sf, recIn', newOut)     -- the last output requested recursion, perform it
            | otherwise = handleAgent otherIns (sf, unRecIn, newOut)                                                     -- no more recursion request, just handle agent as it is and return it, this will transport it back to the outer level
            where
                pastOutputs = fromEvent $ aiRec recIn                           -- at this point we can be sure that there MUST be an aiRec - Event otherwise would make no sense: having an aiRec - Event with a list means, that we are inside a recursion level (either 0 or 1)
                recIn' = recIn { aiRec = Event (newOut : pastOutputs) }         -- append the new output to the past ones

                -- NOTE: need to stop recursion
                unRecIn = recIn { aiRec = NoEvent }

        -- this initiates the recursive simulation call
        handleRecursion :: [AgentIn s m ec]     -- the inputs to the 'other' agents
                                 -> [AgentBehaviour s m ec] -- the signal functions of the 'other' agents
                                 -> (AgentBehaviour s m ec)     -- the OLD signal function of the current agent: it is the SF BEFORE having initiated the recursion
                                 -> (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
                                 -> ([AgentIn s m ec],
                                        Maybe (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec))
        handleRecursion otherIns otherSfs oldSf a@(sf, oldIn, newOut)
            | isJust mayAgent = retAfterRec
            | otherwise = retSelfKilled       -- the agent killed itself, terminate recursion
            where
                -- NOTE: collect self-messages for agent, distribute its messages and environment to others
                retSelfKilled@(otherIns', mayAgent) = handleAgent otherIns a

                (_, newIn, _) = fromJust mayAgent

                otherIns'' = if allowsRecOthers newOut then otherIns' else forbidRecursion otherIns'

                -- TODO: to prevent an endless creation of recursions when running a recursion for more than 1 step one needs to let the recursive agent let know it is inside its own recursion with the same mechanism as letting others now they are inside another recursion.

                -- NOTE: need to add agent, because not included
                allAsfs = otherSfs ++ [oldSf]       -- NOTE: use the old sf, no time
                allAins = otherIns'' ++ [newIn]

                -- TODO: does it make sense to run multiple steps? what is the meaning of it?
                -- TODO: when running for multiple steps it makes sense to specify WHEN the agent of oldSF runs
                -- NOTE: when setting steps to > 1 we end up in an infinite loop
                allStepsRecOuts = (simulate allAins allAsfs False 1.0 1)

                lastStepRecOuts = (last allStepsRecOuts)
                mayRecOut = Data.List.find (\ao -> (aoId ao) == (aiId oldIn)) lastStepRecOuts

                -- TODO: the agent died in the recursive simulation, what should we do?
                retAfterRec = if isJust mayRecOut then
                                seqCallbackRec otherIns otherSfs oldSf (sf, newIn, fromJust mayRecOut)
                                else
                                    retSelfKilled

        forbidRecursion :: [AgentIn s m ec] -> [AgentIn s m ec]
        forbidRecursion ains = map (\ai -> ai { aiRecInitAllowed = False } ) ains

        handleAgent :: [AgentIn s m ec]
                                -> (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
                                -> ([AgentIn s m ec],
                                     Maybe (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec))
        handleAgent otherIns a@(sf, oldIn, newOut) = (otherIns', mayAgent)
            where
                mayAgent = handleKillOrLiveAgent a
                otherIns' = distributeActions otherIns newOut

        handleKillOrLiveAgent :: (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
                                    -> Maybe (AgentBehaviour s m ec, AgentIn s m ec, AgentOut s m ec)
        handleKillOrLiveAgent (sf, oldIn, newOut)
            | kill = Nothing
            | live = Just (sf, newIn', newOut)
            where
                kill = isEvent $ aoKill newOut
                live = not kill
                newIn = oldIn { aiStart = NoEvent,
                                aiState = (aoState newOut),
                                aiMessages = NoEvent,
                                aiEnvPos = (aoEnvPos newOut) }

                -- NOTE: need to handle sending messages to itself because the input of this agent is not in the list of all inputs because it will be replaced anyway by newIn
                newIn' = collectMessagesFor [newOut] newIn

        distributeActions :: [AgentIn s m ec] -> AgentOut s m ec -> [AgentIn s m ec]
        distributeActions otherIns newOut = otherIns1
            where
                 -- NOTE: distribute messages to all other agents
                otherIns0 = distributeMessages otherIns [newOut]
                -- NOTE: passing the changed environment to the next agents
                otherIns1 = passEnvForward newOut otherIns0

        passEnvForward :: AgentOut s m ec -> [AgentIn s m ec] -> [AgentIn s m ec]
        passEnvForward out allIns = map (\ain -> ain { aiEnv = env }) allIns
            where
                env = aoEnv out
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
-- utils
----------------------------------------------------------------------------------------------------------------------
handleCreateAgents :: ([AgentBehaviour s m ec], [AgentIn s m ec])
                        -> AgentOut s m ec
                        -> ([AgentBehaviour s m ec], [AgentIn s m ec])
handleCreateAgents acc@(asfsAcc, ainsAcc) o
    | hasCreateAgents = (asfsAcc ++ newSfs, ainsAcc ++ newAis)
    | otherwise = acc
    where
        newAgentInheritedEnvironment = aoEnv o
        newAgentDefsEvt = aoCreate o
        hasCreateAgents = isEvent newAgentDefsEvt
        newAgentDefs = fromEvent newAgentDefsEvt
        newSfs = map adBeh newAgentDefs
        newAis = map (startingAgentInFromAgentDef newAgentInheritedEnvironment) newAgentDefs

distributeMessages :: [AgentIn s m ec] -> [AgentOut s m ec] -> [AgentIn s m ec]
distributeMessages ains aouts = map (collectMessagesFor aouts) ains

collectMessagesFor :: [AgentOut s m ec] -> AgentIn s m ec -> AgentIn s m ec
collectMessagesFor aouts ai = ai { aiMessages = msgsEvt }
    where
        aid = aiId ai
        aiMsgs = aiMessages ai
        msgsEvt = foldr (\ao accMsgs -> mergeMessages (collectMessagesFrom aid ao) accMsgs) aiMsgs aouts

collectMessagesFrom :: AgentId -> AgentOut s m ec -> Event [AgentMessage m]
collectMessagesFrom aid ao = foldr (\(receiverId, m) accMsgs-> if receiverId == aid then
                                                                mergeMessages (Event [(senderId, m)]) accMsgs
                                                                else
                                                                    accMsgs) NoEvent msgs
    where
        senderId = aoId ao
        msgsEvt = aoMessages ao
        msgs = if isEvent msgsEvt then
                    fromEvent msgsEvt
                    else
                        []
----------------------------------------------------------------------------------------------------------------------