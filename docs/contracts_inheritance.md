# Contracts

```mermaid
graph TD;
EV(EventfulMarket)
ER(SimpleMarketErrorCodes)
OW(Ownable)
SMPL{SimpleMarket}
SUSPSMPL(SuspendableSimpleMarket)
ERRSUSP(SuspendableSimpleMarketErrorCodes)
RER(RestrictedSuspendableSimpleMarketErrorCodes)
RSUSPSMPL{RestrictedSuspendableSimpleMarket}
MEV(MatchingEvents)
DSM(DSMath)
RSMM{RestrictedSuspendableMatchingMarket}
ERRMM(RestrictedSuspendableMatchingMarketErrorCodes)

SMWF{SimpleMarketWithFees}
ERRSMWF(SimpleMarketWithFeesErrorCodes)
EVSMWF(SimpleMarketWithFeesEvents)

CFGSMWF(SimpleMarketConfigurationWithFees)


EV --> SMPL
ER --> SMPL
OW --> SMPL
ERRSUSP --> SUSPSMPL
SMPL --> SUSPSMPL
RER --> RSUSPSMPL
SUSPSMPL --> RSUSPSMPL
ERRMM --> RSMM
RSUSPSMPL --> RSMM
MEV --> RSMM
DSM --> RSMM


ERRSMWF --> SMWF
EVSMWF --> SMWF
SMPL --> SMWF

```