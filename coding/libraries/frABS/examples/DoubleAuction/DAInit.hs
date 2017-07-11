module DoubleAuction.DAInit (
    initDoubleAuction
  ) where

import DoubleAuction.DAModel 
import DoubleAuction.DAAuctioneer
import DoubleAuction.DATrader

import FrABS.Agent.Agent
import FrABS.Env.Environment
import FrABS.Env.Utils

import FRP.Yampa

import Data.List
import Data.Graph.Inductive.Graph
import Data.Graph.Inductive.PatriciaTree

import System.Random
import Control.Monad.Random
import Debug.Trace

initDoubleAuction :: Int -> IO ([DAAgentDef], DAEnvironment)
initDoubleAuction n = 
  do
    auctioneer <- evalRandIO (createDAAuctioneer auctioneer)
    traders <- evalRandIO $ mapM (createDATrader n) [1..n]

    envRng <- newStdGen 

    gr <- evalRandIO $ createAgentNetwork (Complete n)

    let env = createEnvironment
                          Nothing
                          (0,0)
                          neumann
                          ClipToMax
                          []
                          envRng
                          (Just gr)

    return (auctioneer : traders, env)

createDATrader :: Int -> AgentId -> Rand StdGen DAAgentDef
createDATrader n aid = 
    do
        rng <- getSplit

        let h = (fromIntegral aid) / (fromIntegral (n + 1))

        let s = TraderState {
          daTraderOptimism = h,
          daTraderLimitAsset = limitPriceAsset h,
          daTraderLimitLoan = limitPriceLoan h,
          daTraderLimitAssetLoan = (limitPriceAsset h) / (limitPriceLoan h),
          daTraderLimitCollateral = (limitPriceAsset h) - (limitPriceLoan h),

          daTraderCash = cashEndow,
          daTraderAssets = assetEndow,
          daTraderLoansTaken = 0.0,
          daTraderLoansGiven = 0.0
        }

        let adef = AgentDef {
           adId = aid,
           adState = s,
           adEnvPos = (0, 0),
           adConversation = Nothing,
           adInitMessages = NoEvent,
           adBeh = traderAgentBehaviour,
           adRng = rng }

        return adef

createDAAuctioneer :: AgentId -> Rand StdGen DAAgentDef
createDAAuctioneer aid = 
    do
        rng <- getSplit

        let adef = AgentDef {
           adId = aid,
           adState = AuctioneerState,   -- NOTE: again, the auctioneer does not has any domain-specific state
           adEnvPos = (0, 0),
           adConversation = Nothing,
           adInitMessages = NoEvent,
           adBeh = auctioneerBehaviour,
           adRng = rng }

        return adef