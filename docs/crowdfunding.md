# Docs Crowdfunding

## How it works
- Contributors can withdraw at any time before payout is made. Even when goal is reached.
- Payout is made in native currency (GLMR) to the owner. The frontend can direct to moonbeams bridge to get native DOT/KSM/ROC to buy the bulk core.
- Design decision: we can shoot over the goal if the last donator sends too much. Could be prevented if desired.
- Upgradeability
    - Fundraising campaigns are now upgradeable.
    - Deploying upgradeable contracts via factories is pretty hard to implement and prone to errors. Usually you deploy them via `deployProxy` from Openzeppelins Upgrades Plugins in javascript. Therefore I have also added a non-upgradeable Fundraiser contract that can be used with the factory.


---

## Upgradability with XCM
Explaining the process of making the crowdfunding smart contract XCM compatible.