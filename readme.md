# Contracts

```mermaid
graph TD;
EV(EventfulMarket)
ER(SimpleMarketErrorCodes)
OW(Ownable)
SMPL{SimpleMarket}
SUSPSMPL(SuspendableSimpleMarket)
RER(RestrictedSuspendableSimpleMarketErrorCodes)
RSUSPSMPL{RestrictedSuspendableSimpleMarket}
MEV(MatchingEvents)
DSM(DSMath)
MM{MatchingMarket}
EV --> SMPL
ER --> SMPL
OW --> SMPL
SMPL --> SUSPSMPL
RER --> RSUSPSMPL
SUSPSMPL --> RSUSPSMPL
RSUSPSMPL --> MM
MEV --> MM
DSM --> MM

```