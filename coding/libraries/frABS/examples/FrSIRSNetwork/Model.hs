module FrSIRSNetwork.Model (
    SIRSState (..),
    FrSIRSNetworkMsg (..),

    FrSIRSNetworkAgentState,
    FrSIRSNetworkEnvLink,
    FrSIRSNetworkEnvCell,
    FrSIRSNetworkEnvironment,

    FrSIRSNetworkAgentDef,
    FrSIRSNetworkAgentBehaviour,
    FrSIRSNetworkAgentIn,
    FrSIRSNetworkAgentOut,

    FrSIRSNetworkEventSource,
    FrSIRSNetworkMessageSource,
    
    infectivity,
    contactRate,
    illnessDuration,
    immuneDuration,
    initialInfectionProb
  ) where

import FRP.FrABS

------------------------------------------------------------------------------------------------------------------------
-- DOMAIN-SPECIFIC AGENT-DEFINITIONS
------------------------------------------------------------------------------------------------------------------------
data SIRSState = Susceptible | Infected | Recovered deriving (Eq, Show)
data FrSIRSNetworkMsg = Contact SIRSState deriving (Eq, Show)

type FrSIRSNetworkAgentState = SIRSState

type FrSIRSNetworkEnvLink = ()
type FrSIRSNetworkEnvCell = ()
type FrSIRSNetworkEnvironment = Environment FrSIRSNetworkEnvCell FrSIRSNetworkEnvLink

type FrSIRSNetworkAgentDef = AgentDef FrSIRSNetworkAgentState FrSIRSNetworkMsg FrSIRSNetworkEnvCell FrSIRSNetworkEnvLink
type FrSIRSNetworkAgentBehaviour = AgentBehaviour FrSIRSNetworkAgentState FrSIRSNetworkMsg FrSIRSNetworkEnvCell FrSIRSNetworkEnvLink
type FrSIRSNetworkAgentIn = AgentIn FrSIRSNetworkAgentState FrSIRSNetworkMsg FrSIRSNetworkEnvCell FrSIRSNetworkEnvLink
type FrSIRSNetworkAgentOut = AgentOut FrSIRSNetworkAgentState FrSIRSNetworkMsg FrSIRSNetworkEnvCell FrSIRSNetworkEnvLink

type FrSIRSNetworkEventSource = EventSource FrSIRSNetworkAgentState FrSIRSNetworkMsg FrSIRSNetworkEnvCell FrSIRSNetworkEnvLink
type FrSIRSNetworkMessageSource = MessageSource FrSIRSNetworkAgentState FrSIRSNetworkMsg FrSIRSNetworkEnvCell FrSIRSNetworkEnvLink
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
-- MODEL-PARAMETERS
-- average probability of getting infected 
infectivity :: Double
infectivity = 0.05

-- average number of contacts per time-unit
contactRate :: Double
contactRate = 7

illnessDuration :: Double
illnessDuration = 15

immuneDuration :: Double
immuneDuration = 3.0

initialInfectionProb :: Double
initialInfectionProb = 0.2
------------------------------------------------------------------------------------------------------------------------