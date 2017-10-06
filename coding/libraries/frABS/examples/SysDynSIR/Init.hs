module SysDynSIR.Init 
    (
      createSysDynSIR
    ) where

import FRP.FrABS

import SysDynSIR.Model
import SysDynSIR.StockFlow

createSysDynSIR :: [SDDef]
createSysDynSIR = 
    [ susStock
    , infStock
    , recStock
    , infRateFlow
    , recRateFlow
    ]
  where
    initialSusceptibleStockValue = totalPopulation - 1
    initialInfectiousStockValue = 1
    initialRecoveredStockValue = 0

    susStock = createStock susceptibleStockId initialSusceptibleStockValue susceptibleStock
    infStock = createStock infectiousStockId initialInfectiousStockValue infectiousStock
    recStock = createStock recoveredStockId initialRecoveredStockValue recoveredStock

    infRateFlow = createFlow infectionRateFlowId infectionRateFlow
    recRateFlow = createFlow recoveryRateFlowId recoveryRateFlow
------------------------------------------------------------------------------------------------------------------------