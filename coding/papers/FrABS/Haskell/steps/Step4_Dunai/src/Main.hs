{-# LANGUAGE Arrows     #-}
{-# LANGUAGE RankNTypes #-}
module Main where

import System.IO

import Control.Monad.Random
import Control.Monad.Reader
import Control.Monad.Identity
import qualified Data.Map as Map
import FRP.BearRiver
import           Data.Traversable                               as T

import SIR

type AgentId     = Int
type AgentData d = (AgentId, d)

data AgentIn d = AgentIn
  {
    aiId    :: !AgentId
  , aiData  :: ![AgentData d]
  } deriving (Show)

data AgentOut o d = AgentOut
  {
    aoData        :: ![AgentData d]
  , aoObservable  :: !o
  } deriving (Show)

type Agent o d m  = SF m (AgentIn d) (AgentOut o d)

type SIRMonad     = Identity
data SIRMsg       = Contact SIRState deriving (Show, Eq)
type SIRAgentIn   = AgentIn SIRMsg
type SIRAgentOut  = AgentOut SIRState SIRMsg
type SIRAgent     = SF SIRMonad SIRAgentIn SIRAgentOut

agentCount :: Int
agentCount = 100

infectedCount :: Int
infectedCount = 10

rngSeed :: Int
rngSeed = 42

dt :: DTime
dt = 0.1

t :: Time
t = 150

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering

  let g = mkStdGen rngSeed
  let as = initAgents agentCount infectedCount
  let ass = runSimulation g t dt as

  let dyns = aggregateAllStates ass
  let fileName =  "STEP_4_BEARRIVER_DYNAMICS_" ++ show agentCount ++ "agents.m"
  writeAggregatesToFile fileName dyns

runSimulation :: RandomGen g
              => g 
              -> Time 
              -> DTime 
              -> [(AgentId, SIRState)] 
              -> [[SIRState]]
runSimulation g t dt as = map (\aos -> map aoObservable aos) aoss
  where
    steps = floor $ t / dt
    dts = replicate steps ()
    n = length as

    (rngs, _) = rngSplits g n []
    ais = map fst as
    sfs = map (\(g', (_, s)) -> sirAgent g' ais s) (zip rngs as)
    ains = map (\(aid, _) -> agentIn aid) as

    aossIdentity = embed (stepSimulation sfs ains) dts
    aossReader = runReaderT aossIdentity dt
    aoss = runIdentity aossReader

    rngSplits :: RandomGen g => g -> Int -> [g] -> ([g], g)
    rngSplits g 0 acc = (acc, g)
    rngSplits g n acc = rngSplits g'' (n-1) (g' : acc)
      where
        (g', g'') = split g

stepSimulation :: [SIRAgent] -> [SIRAgentIn] -> SF SIRMonad () [SIRAgentOut]
stepSimulation sfs ains =
    dpSwitch
      (\_ sfs' -> (zip ains sfs'))
      sfs
      (switchingEvt) -- if we switch immediately we end up in endless switching, so always wait for 'next'
      cont

  where
    switchingEvt :: SF SIRMonad ((), [SIRAgentOut]) (Event [SIRAgentIn])
    switchingEvt = proc (_, aos) -> do
      let ais      = map aiId ains
          aios     = zip ais aos
          nextAins = distributeData aios
      returnA -< Event nextAins

    cont :: [SIRAgent] -> [SIRAgentIn] -> SF SIRMonad () [SIRAgentOut]
    cont sfs nextAins = stepSimulation sfs nextAins

sirAgent :: RandomGen g => g -> [AgentId] -> SIRState -> SIRAgent
sirAgent g ais  Susceptible = susceptibleAgent g ais
sirAgent g _    Infected    = infectedAgent g
sirAgent _ _    Recovered   = recoveredAgent

susceptibleAgent :: RandomGen g => g -> [AgentId] -> SIRAgent
susceptibleAgent g ais = 
    switch 
      (susceptible g) 
      (const $ infectedAgent g)
  where
    susceptible :: RandomGen g 
                  => g 
                  -> SF SIRMonad SIRAgentIn (SIRAgentOut, Event ())
    susceptible g0 = proc ain -> do
      rec
        g <- iPre g0 -< g'
        let (infected, g') = runRand (gotInfected 1.0 ain) g

      if infected 
        then returnA -< (agentOut Infected, Event ())
        else (do
          makeContact <- occasionally_ g (1 / contactRate) () -< ()
          contactId   <- drawRandomElemSF g                   -< ais

          if isEvent makeContact
            then returnA -< (dataFlow (contactId, Contact Susceptible) $ agentOut Susceptible, NoEvent)
            else returnA -< (agentOut Susceptible, NoEvent))

infectedAgent :: RandomGen g => g -> SIRAgent
infectedAgent g = 
    switch
    infected 
      (const recoveredAgent)
  where
    infected :: SF SIRMonad SIRAgentIn (SIRAgentOut, Event ())
    infected = proc ain -> do
      recEvt <- occasionally_ g illnessDuration () -< ()
      let a = event Infected (const Recovered) recEvt
      -- note that at the moment of recovery the agent can still infect others
      -- because it will still reply with Infected
      let ao = respondToContactWith Infected ain (agentOut a)
      returnA -< (ao, recEvt)

recoveredAgent :: SIRAgent
recoveredAgent = arr (const $ agentOut Recovered)

randomBoolSF :: (RandomGen g, Monad m) => g -> Double -> SF m () Bool
randomBoolSF g p = proc _ -> do
  r <- noiseR ((0, 1) :: (Double, Double)) g -< ()
  returnA -< (r <= p)

drawRandomElemSF :: (RandomGen g, Monad m) => g -> SF m [a] a
drawRandomElemSF g = proc as -> do
  r <- noiseR ((0, 1) :: (Double, Double)) g -< ()
  let len = length as
  let idx = (fromIntegral $ len) * r
  let a =  as !! (floor idx)
  returnA -< a

initAgents :: Int -> Int -> [(AgentId, SIRState)]
initAgents n i = sus ++ inf
  where
    sus = map (\ai -> (ai, Susceptible)) [0..n-i-1]
    inf = map (\ai -> (ai, Infected)) [n-i..n-1]

dataFlow :: AgentData d -> AgentOut o d -> AgentOut o d
dataFlow df ao = ao { aoData = df : aoData ao }

onDataM :: (Monad m) 
        => (acc -> AgentData d -> m acc) 
        -> AgentIn d 
        -> acc 
        -> m acc
onDataM dHdl ai acc = foldM dHdl acc ds
  where
    ds = aiData ai

onData :: (AgentData d -> acc -> acc) -> AgentIn d -> acc -> acc
onData dHdl ai a = foldr (\msg acc'-> dHdl msg acc') a ds
  where
    ds = aiData ai

gotInfected :: RandomGen g => Double -> SIRAgentIn -> Rand g Bool
gotInfected p ain = onDataM gotInfectedAux ain False
  where
    gotInfectedAux :: RandomGen g => Bool -> AgentData SIRMsg -> Rand g Bool
    gotInfectedAux False (_, Contact Infected) = randomBoolM p
    gotInfectedAux x _ = return x

respondToContactWith :: SIRState -> SIRAgentIn -> SIRAgentOut -> SIRAgentOut
respondToContactWith state ain ao = onData respondToContactWithAux ain ao
  where
    respondToContactWithAux :: AgentData SIRMsg -> SIRAgentOut -> SIRAgentOut
    respondToContactWithAux (senderId, Contact _) ao = dataFlow (senderId, Contact state) ao

distributeData :: [(AgentId, AgentOut o d)] -> [AgentIn d]
distributeData aouts = map (distributeDataAux allMsgs) ains -- NOTE: speedup by running in parallel (if +RTS -Nx)
  where
    allMsgs = collectAllData aouts
    ains = map (\(ai, _) -> agentIn ai) aouts 

    distributeDataAux :: Map.Map AgentId [AgentData d]
                      -> AgentIn d
                      -> AgentIn d
    distributeDataAux allMsgs ain = ain'
      where
        receiverId = aiId ain
        msgs = aiData ain -- NOTE: ain may have already messages, they would be overridden if not incorporating them

        mayReceiverMsgs = Map.lookup receiverId allMsgs
        msgsEvt = maybe msgs (\receiverMsgs -> receiverMsgs ++ msgs) mayReceiverMsgs

        ain' = ain { aiData = msgsEvt }

    collectAllData :: [(AgentId, AgentOut o d)] -> Map.Map AgentId [AgentData d]
    collectAllData aos = foldr collectAllDataAux Map.empty aos
      where
        collectAllDataAux :: (AgentId, AgentOut o d)
                              -> Map.Map AgentId [AgentData d]
                              -> Map.Map AgentId [AgentData d]
        collectAllDataAux (senderId, ao) accMsgs 
            | not $ null msgs = foldr collectAllDataAuxAux accMsgs msgs
            | otherwise = accMsgs
          where
            msgs = aoData ao

            collectAllDataAuxAux :: AgentData d
                                 -> Map.Map AgentId [AgentData d]
                                 -> Map.Map AgentId [AgentData d]
            collectAllDataAuxAux (receiverId, m) accMsgs = accMsgs'
              where
                msg = (senderId, m)
                mayReceiverMsgs = Map.lookup receiverId accMsgs
                newMsgs = maybe [msg] (\receiverMsgs -> (msg : receiverMsgs)) mayReceiverMsgs

                -- NOTE: force evaluation of messages, will reduce memory-overhead EXTREMELY
                accMsgs' = seq newMsgs (Map.insert receiverId newMsgs accMsgs)

agentIn :: AgentId -> AgentIn d
agentIn aid = AgentIn {
    aiId    = aid
  , aiData  = []
  }

agentOut :: o -> AgentOut o d
agentOut o = AgentOut {
    aoData        = []
  , aoObservable  = o
  }

randomBoolM :: RandomGen g => Double -> Rand g Bool
randomBoolM p = getRandomR (0, 1) >>= (\r -> return $ r <= p)

occasionally_ :: (Monad m, RandomGen g) 
              => g 
              -> Time 
              -> b 
              -> SF m a (Event b)
occasionally_ g tAvg b 
  | tAvg <= 0 = error "dunai: Non-positive average interval in occasionally."
  | otherwise = proc _ -> do
    r  <- noiseR ((0, 1) :: (Double, Double)) g -< ()
    dt <- arrM_ ask        -< ()
    let p = 1 - exp (-(dt / tAvg))
    returnA -< if r < p then Event b else NoEvent

noiseR :: (RandomGen g, Random b, Monad m) 
       => (b, b) 
       -> g 
       -> SF m a b
noiseR range g0 = loopPre g0 (noiseRAux range)
  where
    noiseRAux :: (RandomGen g, Random b, Monad m) 
              => (b, b) 
              -> SF m (a, g) (b, g)
    noiseRAux range = proc (_, g) -> do
      let (r, g') = randomR range g
      returnA -< (r, g')

dpSwitch :: (Monad m, Traversable col)
         => (forall sf. (a -> col sf -> col (b, sf)))
         -> col (SF m b c) 
         -> SF m (a, col c) (Event d) 
         -> (col (SF m b c) -> d -> SF m a (col c))
         -> SF m a (col c)
dpSwitch rf sfs sfF sfCs = MSF $ \a -> do
  let bsfs = rf a sfs
  res <- T.mapM (\(b, sf) -> unMSF sf b) bsfs
  let cs   = fmap fst res
      sfs' = fmap snd res
  (e,sfF') <- unMSF sfF (a, cs)
  let ct = case e of
            Event d -> sfCs sfs' d
            NoEvent -> dpSwitch rf sfs' sfF' sfCs
  return (cs, ct)
