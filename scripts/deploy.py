#rikbey deploy script
from brownie import FundMe, MockV3Aggregator, network, config
import brownie.network as network

from scripts.helpful_scripts import deploy_mocks, get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS

def deploy_fund_me():
    account = get_account()
    #pass the price feed address to out fundme contract
    #if we are on a persistant network (like rinkeby), use the associated address
    #otherwise, deploy mocks
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()]["eth_usd_price_feed"]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address #use the most recently deployed aggregator
        
    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
        ) #publish_source=True) is used to publish and verify the contract; once deployed go to etherscan.io (rinkeby) and search for it, then you can interact with it
    print(f"Contract deployed to {fund_me.address}")
    return fund_me #this is to have something to return to the fund_and_withdraw test

def main():
    deploy_fund_me()