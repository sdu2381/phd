module SIRSequentialHack where
import System.IO
import System.IO.Unsafe
import System.Random

------------------------------------------------------------------------------------------------------
-- TEST
data MsgType d = Start | Stop | Domain d deriving (Show)
data MsgDomain = A | B | C deriving (Show, Eq)

matchMsgTypeNum :: (Num d, Eq d, Show d) => MsgType d -> IO ()
matchMsgTypeNum Start = putStr "matchMsgTypeNum: Start"
matchMsgTypeNum Stop = putStr "matchMsgTypeNum: Stop"
matchMsgTypeNum (Domain x) = putStr ("matchMsgTypeNum: Domain " ++ show x)

matchMsgTypeBool :: MsgType Bool -> IO ()
matchMsgTypeBool Start = putStr "matchMsgTypeBool: Start"
matchMsgTypeBool Stop = putStr "matchMsgTypeBool: Stop"
matchMsgTypeBool (Domain True) = putStr ("matchMsgTypeBool: Domain True")
matchMsgTypeBool (Domain False) = putStr ("matchMsgTypeBool: Domain False")

matchMsgTypeDom ::  MsgType MsgDomain -> IO ()
matchMsgTypeDom Start = putStr "matchMsgTypeDom: Start"
matchMsgTypeDom Stop = putStr "matchMsgTypeDom: Stop"
matchMsgTypeDom (Domain A) = putStr ("matchMsgTypeDom: Domain A")
matchMsgTypeDom (Domain B) = putStr ("matchMsgTypeDom: Domain B")
matchMsgTypeDom (Domain C) = putStr ("matchMsgTypeDom: Domain C")
------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
-- SEQUENTIAL APPROACH
type AgentId = Int

data MessageType = AgentStart | AgentStop | AgentContent deriving (Show)
data Message p = Message {
  sender :: AgentId,
  receiver :: AgentId,
  msgType :: MessageType,
  content :: Maybe p
} deriving (Show)
              
data Agent s p = Agent
  {
    agentId :: AgentId,
    agentMBox :: [Message p],
    agentState :: s         
  }

createAgent :: Int -> s -> Agent s p
createAgent i initState = Agent { agentId = i, agentMBox = [], agentState = initState }

processAgents :: [Agent s p] -> [Agent s p]
processAgents as = as

emptyMessage :: MessageType -> Message p
emptyMessage t = Message{msgType=t, sender=(-1), receiver=(-1), content=Nothing}

startAgents :: [Agent s p] -> [Agent s p]
startAgents as = map (sendMessage $ emptyMessage AgentStart) as

stopAgents :: [Agent s p] -> [Agent s p]
stopAgents as = map (sendMessage $ emptyMessage AgentStop) as

sendMessage :: Message p -> Agent s p -> Agent s p
sendMessage msg a = a { agentMBox = newMBox }
  where
    mbox = agentMBox a
    newMBox = mbox ++ [msg]

showAgent :: (Show s, Show p) => Agent s p -> String
showAgent a = "Agent " ++ show id ++ " state: " ++ show state ++ ", mbox: " ++ show mbox
  where
    id = agentId a
    state = agentState a
    mbox = agentMBox a

printAgents :: (Show s, Show p) => [Agent s p] -> IO ()
printAgents [] = return ()
printAgents (a:as) = do
  putStr (showAgent a)
  putStr "\n"
  printAgents as

-- SIR-specific stuff -------------------------------------------------------------------------

data SIRState = Susceptible | Infected | Recovered deriving (Show, Eq)

data SIRProtocoll = ContactSusceptible | ContactInfected | ContactRecovered deriving (Show)
data SIRAgentState = SIRAgentState
  {
    sirState :: SIRState,
    daysInfected :: Int
  } deriving (Show)
                     
type SIRAgent = Agent SIRAgentState SIRProtocoll

populationCount :: Int
populationCount = 10

simStepsCount :: Int
simStepsCount = 10

infectionProb :: Float
infectionProb = 0.5

daysInfectous :: Int
daysInfectous = 3

main :: IO()
main = do
  let agents = populateSIR populationCount
  --let startedAgents = startAgents agents
  let allAgents = executeSimSteps simStepsCount agents
  --printAgents (last allAgents)
  stepThrough 0 allAgents

stepThrough :: Int -> [[SIRAgent]] -> IO ()
stepThrough i ass = do
  putStr "\nPress Enter to advance one step\n"
  c <- getChar
  putStr ("t = " ++ (show i) ++ "\n" )
  printAgents $ ass !! i
  stepThrough (i+1) ass
  
executeSimSteps :: Int -> [SIRAgent] -> [[SIRAgent]]
executeSimSteps n initAs = foldr (\i acc -> acc ++ [(simStep'' $ last acc)] ) [initAs] [1..n]

simStep :: [SIRAgent] -> [SIRAgent]
simStep as = map recoverAgent $ map processMessages as

simStep' :: [SIRAgent] -> [SIRAgent]
simStep' as = foldr (\a acc -> randomContacts a acc) initialAcc asAfterRecover
 where
    asAfterMsgProc = map processMessages as
    asAfterRecover = map recoverAgent asAfterMsgProc
    initialAcc = asAfterRecover

simStep'' :: [SIRAgent] -> [SIRAgent]
simStep'' as = newAs
 where
    asAfterMsgProc = map processMessages as
    asAfterRecover = map recoverAgent asAfterMsgProc
    (randAgent, randIdx) = getRandAgent as
    newAs = randomContacts randAgent asAfterRecover
    
getRandAgent :: [SIRAgent] -> (SIRAgent, Int)
getRandAgent as = (as !! randIdx, randIdx)
  where
    agentCount = length as
    randIdx = unsafePerformIO (getStdRandom (randomR (0, agentCount-1)))
    
randomContacts :: SIRAgent -> [SIRAgent] -> [SIRAgent]
randomContacts a as = replaceAgent newRandAgent randIdx as
  where
    (randAgent, randIdx) = getRandAgent as
    infectionState = sirState $ agentState a
    msgContent = if infectionState==Infected then (Just ContactInfected) else Nothing
    msg = Message{msgType=AgentContent, sender=(-1), receiver=(-1), content=msgContent}
    newRandAgent = sendMessage msg randAgent

replaceAgent :: SIRAgent -> Int -> [SIRAgent] -> [SIRAgent]
replaceAgent newAgent idx as = frontAs ++ [newAgent] ++ tailAs
  where
    splitTup = splitAt idx as
    frontAs = fst splitTup
    tailAs = tail (snd splitTup)

processMessages :: SIRAgent -> SIRAgent
processMessages initA = agentClearMBox
  where
    messages = agentMBox initA
    agentAfterProc = foldr (\msg a -> matchMessageType msg a) initA messages
    agentClearMBox = agentAfterProc{agentMBox=[]} 

recoverAgent :: SIRAgent -> SIRAgent
recoverAgent a
  | infectionState == Infected = if (remainingDays - 1) == 0 then a {agentState=SIRAgentState{sirState=Recovered, daysInfected=0}} else a {agentState=SIRAgentState{sirState=Infected, daysInfected=remainingDays-1}}
  | otherwise = a
  where
    as = agentState a
    infectionState = sirState as
    remainingDays = daysInfected as

matchMessageType :: Message SIRProtocoll -> SIRAgent -> SIRAgent
matchMessageType (Message {msgType=AgentContent, content=c}) a = messageReceived c a
matchMessageType Message {msgType=AgentStart} a = agentStarted a
matchMessageType Message {msgType=AgentStop} a = agentStoped a

messageReceived :: Maybe SIRProtocoll -> SIRAgent -> SIRAgent
messageReceived (Just ContactSusceptible) a = a
messageReceived (Just ContactInfected) a = contactWithInfected a
messageReceived (Just ContactRecovered) a = a
messageReceived Nothing a = a

contactWithInfected :: SIRAgent -> SIRAgent
contactWithInfected a
  | oldSirState == Susceptible = if randInfection then a {agentState=SIRAgentState{sirState=Infected, daysInfected=daysInfectous}} else a
  | otherwise = a                                                                                                           
  where
    oldAgentState = agentState a
    oldSirState = sirState $ agentState a
    randInfection = randomBool infectionProb

agentStarted :: SIRAgent -> SIRAgent
agentStarted a = a

agentStoped :: SIRAgent -> SIRAgent
agentStoped a = a

createSIRAgent :: Int -> SIRAgent
createSIRAgent i = createAgent i randState
  where
     randInfection = randomBool infectionProb
     randState = if randInfection then SIRAgentState{sirState=Infected, daysInfected=daysInfectous} else SIRAgentState{sirState=Susceptible, daysInfected=0}
                                               
populateSIR :: Int -> [SIRAgent]
populateSIR n = foldr (\i acc -> (createSIRAgent i) : acc) [] [1..n]

randomBool :: Float -> Bool
randomBool p = p >= rand
  where
    rand = unsafePerformIO (getStdRandom (randomR (0.0, 1.0))) 
------------------------------------------------------------------------------------------------------
