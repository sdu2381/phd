{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts  #-}
module SugarScape.Agent.Interface
  ( AgentMSF
  , AgentT
  
  , AgentDef (..)
  , AgentOut (..)

  , observable
  
  , agentOut
  , agentOutMergeLeft
  , agentOutMergeRight

  , isDead
  , kill
  , newAgent
  ) where

import Control.Concurrent.STM.TMVar
import Control.Monad.Reader
import Data.MonadicStreamFunction

import SugarScape.Core.Common

type AgentT m e = ReaderT (ABSCtx e) m
-- NOTE: an agent is a MSF not a SF! we don't need the ReaderT Double 
-- in SugarScape (we switch MSFs which would resert time anyway)
type AgentMSF m e o = MSF (AgentT m e) (ABSEvent e) (AgentOut m e o)

data AgentDef m e o = AgentDef
  { adId      :: !AgentId
  , adSf      :: AgentMSF m e o
  , adInitObs :: !o
  }

data AgentOut m e o = AgentOut 
  { aoKill       :: !Bool
  , aoCreate     :: ![AgentDef m e o]
  , aoObservable :: !o
  , aoReplyVar   :: !(Maybe (TMVar e))
  }

agentOut :: o -> AgentOut m e o
agentOut o = AgentOut 
  { aoKill       = False
  , aoCreate     = []
  , aoObservable = o
  , aoReplyVar   = Nothing
  }

isDead :: AgentOut m e o -> Bool
isDead = aoKill

kill :: AgentOut m e o -> AgentOut m e o
kill ao = ao { aoKill = True }

observable :: AgentOut m e o -> o
observable = aoObservable

newAgent :: AgentDef m e o
         -> AgentOut m e o 
         -> AgentOut m e o
newAgent adef ao 
  = ao { aoCreate = adef : aoCreate ao }

agentOutMergeLeft :: AgentOut m e o
                  -> AgentOut m e o
                  -> AgentOut m e o
agentOutMergeLeft aoLeft aoRight
  = mergeAgentOut
      (aoObservable aoLeft)
      (pickMaybe (aoReplyVar aoLeft) (aoReplyVar aoRight))
      aoLeft
      aoRight

agentOutMergeRight :: AgentOut m e o
                   -> AgentOut m e o
                   -> AgentOut m e o
agentOutMergeRight aoLeft aoRight 
  = mergeAgentOut 
      (aoObservable aoRight)
      (pickMaybe (aoReplyVar aoRight) (aoReplyVar aoLeft))
      aoLeft
      aoRight 

mergeAgentOut :: o
              -> Maybe (TMVar e) 
              -> AgentOut m e o
              -> AgentOut m e o
              -> AgentOut m e o
mergeAgentOut o rv aoLeft aoRight = AgentOut 
  { aoKill       = aoKill aoLeft || aoKill aoRight
  , aoCreate     = aoCreate aoLeft ++ aoCreate aoRight
  , aoObservable = o
  , aoReplyVar   = rv 
  }

pickMaybe :: Maybe a
          -> Maybe a
          -> Maybe a
pickMaybe (Just a) Nothing  = Just a
pickMaybe Nothing (Just a)  = Just a
pickMaybe Nothing Nothing   = Nothing
pickMaybe (Just _) (Just _) = error "Can't select from both Just"