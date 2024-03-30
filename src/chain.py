import os
import sys
from dotenv import load_dotenv
from web3 import Web3

load_dotenv()

rpc_url = os.environ.get('RPC_URL')
if not rpc_url:
    sys.exit('RPC_URL must be set')

wallet_address = os.environ.get('WALLET_ADDRESS') 
if not wallet_address:
    sys.exit('WALLET_ADDRESS must be set')

web3 = Web3(Web3.HTTPProvider(rpc_url))
print(f"Is connected: {web3.is_connected()}")

print(f"gas price: {web3.eth.gas_price} BNB")
print(f"current block number: {web3.eth.block_number}")
print(f"number of current chain is {web3.eth.chain_id}")
